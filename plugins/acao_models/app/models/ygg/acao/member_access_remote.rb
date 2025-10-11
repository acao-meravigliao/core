# frozen_string_literal: true
#
# Copyright (C) 2024-2024, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#


module Ygg
module Acao

class MemberAccessRemote < Ygg::PublicModel
  self.table_name = 'acao.member_access_remotes'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  belongs_to :member,
             class_name: 'Ygg::Acao::Member'

  belongs_to :remote,
             class_name: 'Ygg::Acao::AccessRemote'

  def validity_ranges
    member ? member.access_validity_ranges : []
  end

  def validity_start
    validity_ranges.first ? validity_ranges.first.begin : nil
  end

  def validity_end
   validity_ranges.first ? validity_ranges.first.end : nil
  end

  def self.sync_from_maindb!(debug: 0)
    Ygg::Toolkit.merge(
      l: Ygg::Acao::MainDb::Tessera.where('len(tag) < 10').order('LOWER(tag)').lock,
      r: self.joins(:remote).merge(Ygg::Acao::AccessRemote.order(symbol: :asc )).lock,
      l_cmp_r: lambda { |l,r| l.tag.downcase <=> r.remote.symbol },
      l_to_r: lambda { |l|

        puts "  TESSERA => ACCESSREMOTE ADD #{l.tag.downcase}" if debug >= 1

        member = Ygg::Acao::Member.find_by(code: l.codice_socio)
        if !member
          puts "ACCESSREMOTE MISSING MEMBER #{l.codice_socio}!!!! NOT SYNCING ROW"
          return
        end

        remote = Ygg::Acao::AccessRemote.find_by(symbol: l.tag.downcase)
        if !member
          puts "ACCESSREMOTE MISSING REMOTE #{l.tag.downcase}!!!! NOT SYNCING ROW"
          return
        end

        create(
          member: member,
          remote: remote,
        )
      },
      r_to_l: lambda { |r|
        puts "  ACCESS REMOTE DEL #{r.remote.symbol}"
        r.destroy
      },
      lr_update: lambda { |l,r|
        puts "  ACCESS REMOTE CHECK #{l.tag.downcase}" if debug >= 3

        ####
      }
    )
  end

end

end
end
