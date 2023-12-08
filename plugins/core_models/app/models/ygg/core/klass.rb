#
# Copyright (C) 2013-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Klass < Ygg::PublicModel
  self.table_name = 'core.klasses'

  self.porn_migration += [
    [ :must_have_column, { name: 'id', type: :uuid, null: false, default_function: 'gen_random_uuid()' } ],
    [ :must_have_column, { name: 'name', type: :string, null: false, limit: 128 } ],

    [ :must_have_index, {:columns=>["name"], :unique=>true}],
  ]

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  has_many :members_role_defs,
           class_name: '::Ygg::Core::Klass::MembersRoleDef',
           embedded: true,
           dependent: :destroy,
           autosave: true

  has_many :collection_role_defs,
           class_name: '::Ygg::Core::Klass::CollectionRoleDef',
           embedded: true,
           dependent: :destroy,
           autosave: true

  def klass
    name.constantize
  end

  def summary
    name
  end

  def self.all_classes
    all.map { |x| x.klass rescue nil }.compact
  end

  def self.export(filename:)
    File.write(filename, all.map { |x|
      [ x.name,
        collection_roles: Hash[
          x.collection_role_defs.map { |role|
            [ role.name,
               {
                interface: role.interface,
                all_readable: role.all_readable,
                all_writable: role.all_writable,
                allow_all_actions: role.allow_all_actions,
                actions: role.actions,
                attrs: role.attrs,
               }
            ]
          }
        ],
        members_roles: Hash[
          x.members_role_defs.map { |role|
            [ role.name,
               {
                interface: role.interface,
                all_readable: role.all_readable,
                all_writable: role.all_writable,
                allow_all_actions: role.allow_all_actions,
                actions: role.actions,
                attrs: role.attrs,
               }
            ]
          }
        ]
      ]
    }.to_yaml)
  end

  def self.import(filename:)
    transaction do
      YAML.load_file(filename).each do |cls,data|
        k=Ygg::Core::Klass.find_by(name: cls)

        if k
          if data[:members_roles]
            data[:members_roles].each { |role_name,role_data|
              r = k.members_role_defs.find_or_initialize_by(name:role_name, interface: 'rest')
              r.all_readable = role_data[:all_readable]
              r.all_writable = role_data[:all_writable]
              r.allow_all_actions = role_data[:allow_all_actions]
              r.actions = role_data[:actions]
              r.attrs = role_data[:attrs]
              r.save!
            }
          end

          if data[:collection_roles]
            data[:collection_roles].each { |role_name,role_data|
              r = k.collection_role_defs.find_or_initialize_by(name:role_name, interface: 'rest')
              r.all_readable = role_data[:all_readable]
              r.all_writable = role_data[:all_writable]
              r.allow_all_actions = role_data[:allow_all_actions]
              r.actions = role_data[:actions]
              r.attrs = role_data[:attrs]
              r.save!
            }
          end
        end
      end
    end
  end
end

end
end
