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

  self.porn_migration += [
    [ :must_have_column, { name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "person_id", type: :integer, default: nil, limit: 4, null: false}],
    [ :must_have_column, {name: "code", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_column, {name: "descr", type: :string, default: nil, limit: 255, null: true}],
    [ :must_have_column, {name: "notes", type: :text, default: nil, null: true}],
    [ :must_have_index, {columns: ["person_id"], unique: false}],
    [ :must_have_index, {columns: ["code"], unique: true}],
    [ :must_have_fk, {to_table: "core_people", column: "person_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  belongs_to :person,
             class_name: '::Ygg::Core::Person',
             optional: true

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
