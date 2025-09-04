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

class KeyFob < Ygg::PublicModel
  self.table_name = 'acao.key_fobs'

  belongs_to :member,
             class_name: '::Ygg::Acao::Member', optional: true # Workaround for sync_to_maindb
#  belongs_to :member,
#             class_name: '::Ygg::Acao::Member'

  include Ygg::Core::Versioned
  self.versioning_insensitive_attributes += [
    :last_notify_run,
  ]

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  idxc_cached
  self.idxc_sensitive_attributes = [
    :person_id,
  ]

  def self.code_from_faac(code)
    code ? code.to_i(8).to_s(16).rjust(10, '0') : nil
  end

  def code_for_faac
    code ? code.to_i(16).to_s(8).rjust(14, '0') : nil
  end

  def self.sync_from_maindb!(debug: 0)
    Ygg::Toolkit.merge(
      l: Ygg::Acao::MainDb::Tessera.where('len(tag) = 10').order('LOWER(tag)').lock,
      r: self.all.order(code: :asc).lock,
      l_cmp_r: lambda { |l,r| l.tag.downcase <=> r.code.downcase },
      l_to_r: lambda { |l|

        puts "  TESSERA => KEYFOB ADD #{l.tag.downcase}" if debug >= 1

        member = Ygg::Acao::Member.find_by(code: l.codice_socio)
        if !member
          puts "KEYFOB MISSING MEMBER #{l.codice_socio}!!!! NOT SYNCING ROW"
          return
        end

        create(
          member: member,
          code: l.tag.downcase,
          descr: "From Aliandre",
          media_type: 'RFID',
          src: 'ALIANDRE',
          src_id: l.id,
        )
      },
      r_to_l: lambda { |r|
        puts "  KEYFOB DEL #{r.code.downcase}"
        r.destroy
      },
      lr_update: lambda { |l,r|
        puts "  KEYFOB CHECK #{l.tag.downcase}" if debug >= 3

        ####
      }
    )
  end

  ################## Replica ###################

  include Ygg::Core::Replicable

  define_default_provisionable_controller(self)
  class ProvisioningController
    view :_default_ do
      attribute(:gate) { show! }
    end
  end

  def replicas_needed
    replicas = {}

    Ygg::Acao::Gate.all.each do |gate|
      replicas['GATE:' + gate.agent.exchange] = {
        descr: "Gate '#{gate.agent.descr}'",
        function: 'GATE',
        data: {
          agent: gate.agent.exchange,
        },
        insensitive_attributes: [
          :version,
          :descr,
          :notes,
        ],
      }
    end

    replicas
  end

  def replica_update(replica, **args)
    case replica.function
    when 'GATE'
      Ygg::Core::Taask.create!(
        agent: replica.data[:agent],
        operation: 'UPDATE',
        description: 'Gate configuration',
        expected_completion: Time.now + 30.seconds,
        request_data: {
          keyfob: ProvisioningController.new.ar_hash(self, format: :deep),
          or_create: true,
        },
        notifies: [ Ygg::Core::Taask::Notify.new(obj: replica) ],
        obj: self,
      )
    else
      raise "Unknown replica function '#{replica.function}'"
    end
  end

  def replica_destroy(replica)
    case replica.function
    when 'GATE'
      Ygg::Core::Taask.create!(
        agent: replica.data[:agent],
        operation: 'DELETE',
        expected_completion: Time.now + 30.seconds,
        description: 'Remove from Gate',
        request_data: { id: id, ignore_not_found: true },
        notifies: [ Ygg::Core::Taask::Notify.new(obj: replica) ],
        obj: self,
      )
    else
      raise "Unknown replica function '#{replica.function}'"
    end
  end
end

end
end
