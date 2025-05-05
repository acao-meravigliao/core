#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ml

class List < Ygg::PublicModel
  self.table_name = 'ml.lists'

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "name", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "descr", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "symbol", type: :string, default: nil, limit: 32, null: true}],

    [ :must_have_index, {columns: ["symbol"], unique: true}],
  ]

  has_many :members,
           class_name: '::Ygg::Ml::List::Member',
           dependent: :destroy

  has_many :addresses,
           class_name: '::Ygg::Ml::Address',
           through: :members

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  class Member < Ygg::BasicModel
    self.table_name = 'ml.list_members'

    belongs_to :list,
               class_name: '::Ygg::Ml::List'

    belongs_to :address,
               class_name: '::Ygg::Ml::Address'

    belongs_to :owner,
               polymorphic: true,
               optional: true

    define_default_log_controller(self)
  end

  def sync_from_people!(people:, time: Time.now)
    current_members = members.where(owner_type: 'Ygg::Core::Person').order(owner_id: :asc)

    self.class.merge(l: people, r: current_members,
      l_cmp_r: lambda { |l,r| l.id <=> r.owner_id },
      l_to_r: lambda { |l|
        l.person.contacts.where(type: 'email').each do |contact|
          addr = Ygg::Ml::Address.find_or_create_by(addr: contact.value, addr_type: 'EMAIL')
          addr.name = l.person.name
          addr.save!

          members << Ygg::Ml::List::Member.new(
            address: addr,
            subscribed_on: Time.now,
            owner: l,
          )
        end
      },
      r_to_l: lambda { |r|
        r.destroy
      },
      lr_update: lambda { |l,r|
        r.address.name = l.person.name
        r.address.save!
      },
    )
  end

  def sync_to_mailman!(list_name:, do_add: true, do_remove: true, dry_run: Rails.application.config.acao.soci_ml_dry_run)
    l_full_emails = Hash[addresses.where(addr_type: 'EMAIL').order(addr: :asc).map { |x| [ x.addr.downcase, x.name ] }]

    l_emails = l_full_emails.keys.sort
    r_emails = []

    IO::popen([ '/usr/bin/ssh', '-i', '/var/lib/yggdra/lino', 'root@lists.acao.it', '/usr/sbin/list_members', list_name ]) do |io|
      data = io.read
      io.close

      if !$?.success?
        raise "Cannot list list members"
      end

      r_emails = data.split("\n").map { |x| x.strip.downcase }.sort
    end

    members_to_add = []
    members_to_remove = []

    self.class.merge(l: l_emails, r: r_emails,
      l_cmp_r: lambda { |l,r| l <=> r },
      l_to_r: lambda { |l|
        if do_add
          members_to_add << "#{l_full_emails[l]} <#{l}>"
        end
      },
      r_to_l: lambda { |r|
        if do_remove
          members_to_remove << r
        end
      },
      lr_update: lambda { |l,r|
      }
    )

    if members_to_add.any?
      puts "MAILMAN MEMBERS TO ADD TO LIST #{list_name}:\n#{members_to_add}"

      if !dry_run
        IO::popen([ '/usr/bin/ssh', '-i', '/var/lib/yggdra/lino', 'root@lists.acao.it', '/usr/sbin/add_members',
                      '-r', '-', '--admin-notify=n', '--welcome-msg=n', list_name ], 'w') do |io|
          io.write(members_to_add.join("\n"))
          io.close
        end
      end
    end

    if members_to_remove.any?
      puts "MAILMAN MEMBERS TO REMOVE FROM LIST #{list_name}:\n#{members_to_remove}"

      if !dry_run
        IO::popen([ '/usr/bin/ssh', '-i', '/var/lib/yggdra/lino', 'root@lists.acao.it', '/usr/sbin/remove_members',
                      '--file', '-', '--nouserack', '--noadminack', list_name ], 'w') do |io|
          io.write(members_to_remove.join("\n"))
          io.close
        end
      end
    end
  end

  def self.merge(l:, r:, l_cmp_r:, l_to_r:, r_to_l:, lr_update:)

    r_enum = r.each
    l_enum = l.each

    r = r_enum.next rescue nil
    l = l_enum.next rescue nil

    while r || l
      if !l || (r && l_cmp_r.call(l, r) == 1)
        r_to_l.call(r)

        r = r_enum.next rescue nil
      elsif !r || (l &&  l_cmp_r.call(l, r) == -1)
        l_to_r.call(l)

        l = l_enum.next rescue nil
      else
        lr_update.call(l, r)

        l = l_enum.next rescue nil
        r = r_enum.next rescue nil
      end
    end
  end

  def label
    name
  end

  def summary
    "#{name} - #{descr}"
  end
end

end
end
