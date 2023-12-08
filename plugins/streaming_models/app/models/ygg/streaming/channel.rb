#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#


module Ygg
module Streaming

class Channel < Ygg::PublicModel
  self.table_name = 'str_channels'

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: true}],
    [ :must_have_column, {name: "name", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "descr", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "poster", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "symbol", type: :string, default: nil, limit: 32, null: false}],
    [ :must_have_column, {name: "agent_id", type: :integer, default: nil, limit: 4, null: true}],

    [ :must_have_index, {columns: ["agent_id"], unique: false}],

    [ :must_have_fk, {to_table: "core_agents", column: "agent_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  belongs_to :agent,
             class_name: 'Ygg::Core::Agent',
             optional: true

  has_many :variants,
           class_name: 'Ygg::Streaming::Channel::Variant',
           embedded: true,
           autosave: true,
           dependent: :destroy

  include Ygg::Core::Versioned
  self.versioning_insensitive_attributes += [
  ]

  ################## Replica ###################

  include Ygg::Core::Replicable

  define_default_provisionable_controller(self)
  class ProvisioningController
    view :_default_ do
      attribute :variants do
        show!
      end
    end
  end

  def replicas_needed
    replicas = {}

    replicas['YGG_AGENTS:' + agent.exchange] = {
      descr: "HLS Agent '#{agent.descr}'",
      function: 'HLS_AGENT',
      data: {
        agent: agent.exchange,
      },
      insensitive_attributes: [
        :version,
      ],
    }

    replicas
  end

  def replica_update(replica, **args)
    case replica.function
    when 'HLS_AGENT'
      Ygg::Core::Taask.create!(
        agent: replica.data[:agent],
        operation: 'CHANNEL_UPDATE',
        description: 'Agent configuration',
        expected_completion: Time.now + 30.seconds,
        notifies: [ Ygg::Core::Taask::Notify.new(obj: replica) ],
        obj: self,
        request_data: {
          channel: ProvisioningController.new.ar_hash(self, format: :deep),
          or_create: true,
        },
      )
    else
      raise "Unknown replica function '#{replica.function}'"
    end
  end

  def replica_destroy(replica)
    case replica.function
    when 'HLS_AGENT'
      Ygg::Core::Taask.create!(
        agent: replica.data[:agent],
        operation: 'CHANNEL_DELETE',
        expected_completion: Time.now + 30.seconds,
        description: 'Agent configuration',
        notifies: [ Ygg::Core::Taask::Notify.new(obj: replica) ],
        obj: self,
        request_data: { channel: ProvisioningController.new.ar_hash(self, format: :deep), },
      )
    else
      raise "Unknown replica function '#{replica.function}'"
    end
  end
end

end
end
