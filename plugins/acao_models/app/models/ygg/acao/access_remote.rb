# frozen_string_literal: true
#
# Copyright (C) 2017-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#


module Ygg
module Acao

class AccessRemote < Ygg::PublicModel
  self.table_name = 'acao.access_remotes'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  idxc_cached
  self.idxc_sensitive_attributes = [
    :person_id,
  ]

  belongs_to :member,
             class_name: 'Ygg::Acao::Member',
             optional: true

  gs_rel_map << { from: :access_remote, to: :member, to_cls: 'Ygg::Acao::Member', from_key: 'member_id', }

  def self.code_from_faac(code)
    code.to_i(8).to_s(16).rjust(10, '0')
  end

  def code_for_faac(code)
    code ? code.to_i(16).to_s(8).rjust(8, '0') : nil
  end

  def ch1_code_for_faac
    code_for_faac(ch1_code)
  end

  def ch2_code_for_faac
    code_for_faac(ch2_code)
  end

  def ch3_code_for_faac
    code_for_faac(ch3_code)
  end

  def ch4_code_for_faac
    code_for_faac(ch4_code)
  end


  def validity_ranges
    member ? member.access_validity_ranges : []
  end

  def validity_start
    validity_ranges.first ? validity_ranges.first.begin : nil
  end

  def validity_end
   validity_ranges.first ? validity_ranges.first.end : nil
  end

  #def self.sync_from_maindb!(debug: 0)
  #  Ygg::Toolkit.merge(
  #    l: Ygg::Acao::MainDb::Tessera.where('len(tag) > 0').where('len(tag) < 10').order('LOWER(tag)').lock,
  #    r: self.joins(:remote).merge(Ygg::Acao::AccessRemote.order(symbol: :asc )).lock,
  #    l_cmp_r: lambda { |l,r| l.tag.downcase <=> r.remote.symbol },
  #    l_to_r: lambda { |l|

  #      puts "  TESSERA => ACCESSREMOTE ADD #{l.tag.downcase}" if debug >= 1

  #      member = Ygg::Acao::Member.find_by(code: l.codice_socio)
  #      if !member
  #        puts "ACCESSREMOTE MISSING MEMBER #{l.codice_socio}!!!! NOT SYNCING ROW"
  #        return
  #      end

  #      remote = Ygg::Acao::AccessRemote.find_by(symbol: l.tag.downcase)
  #      if !member
  #        puts "ACCESSREMOTE MISSING REMOTE #{l.tag.downcase}!!!! NOT SYNCING ROW"
  #        return
  #      end

  #      create(
  #        member: member,
  #        remote: remote,
  #      )
  #    },
  #    r_to_l: lambda { |r|
  #      puts "  ACCESS REMOTE DEL #{r.remote.symbol}"
  #      r.destroy
  #    },
  #    lr_update: lambda { |l,r|
  #      puts "  ACCESS REMOTE CHECK #{l.tag.downcase}" if debug >= 3

  #      ####
  #    }
  #  )
  #end

end

end
end
