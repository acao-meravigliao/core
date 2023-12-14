#
# Copyright (C) 2008-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Replica < ActiveRecord::Base
  self.table_name = 'core.replicas'

  include Ygg::Core::HasPornMigration

  self.porn_migration += [
    [ :must_have_column, { name: 'id', type: :uuid, null: false, default_function: 'gen_random_uuid()' } ],
    [ :must_have_column, { name: 'obj_type', type: :string, null: false } ],
    [ :must_have_column, { name: 'obj_id', type: :integer, null: false } ],
    [ :must_have_column, { name: 'identifier', type: :string, null: false } ],
    [ :must_have_column, { name: 'state', type: :string, null: false, limit: 32, default: 'UNKNOWN' } ],
    [ :must_have_column, { name: 'version_needed', type: :integer, null: false } ],
    [ :must_have_column, { name: 'version_pending', type: :integer, null: false } ],
    [ :must_have_column, { name: 'version_done', type: :integer, null: false } ],
    [ :must_have_column, { name: 'function', type: :string, limit: 32, null: true } ],
    [ :must_have_column, { name: 'descr', type: :string } ],
    [ :must_have_column, { name: 'data', type: :json } ],
  ]

  belongs_to :obj,
             polymorphic: true,
             autosave: false,
             optional: true

  include ActiveRest::Model
  include Ygg::Core::DeepDirty
  include Ygg::Core::Lifecycle

  include Taskable

  task_completed do |task|
    completed!
  end

  task_failed do |task|
    failed!
  end

  task_canceled do |task|
    change_state!('IDLE')
    self.version_pending = version_done
    save!
  end

  class InvalidTransition < StandardError
    def initialize(state, event)
      super("Received unexpected event '#{event}' in state '#{state}'")
    end
  end

  def data
    read_attribute(:data).try(:symbolize_keys!)
  end

  def completed!(version: version_pending)
    self.version_done = version
    self.save!

    Ygg::Core::ReplicaNotify.check_for(obj: obj)

    if state == 'DESTROYING'
      destroy!
    else
      change_state!('IDLE')
      save!

      if version_done < version_needed
        Ygg::Core::Replica.process_all_async!
      end
    end
  end

  def failed!
    change_state!('FAILURE')
    self.version_pending = version_done
    save!
  end

  def process!
    transaction do
      lock!

      # Avoid crashing if there is some inconsistency in the database
      if !obj
        logger.warn "Replica #{id} has nil object!"
        return
      end

      case state
      when 'UNKNOWN'
        change_state!('UPDATING')
        self.version_pending = obj.version
        obj.replica_update(self, create: true)
        save!

        Ygg::Core::ReplicaNotify.find_or_create_by!(obj: obj, notify_obj: obj, version_needed: obj.version, identifier: 'DEFAULT_NOTIFICATION')

      when 'FAILURE'
        change_state!('UPDATING')
        self.version_pending = obj.version
        obj.replica_update(self)
        save!

        Ygg::Core::ReplicaNotify.find_or_create_by!(obj: obj, notify_obj: obj, version_needed: obj.version, identifier: 'DEFAULT_NOTIFICATION')

      when 'IDLE'
        if version_done < version_needed
          change_state!('UPDATING')
          self.version_pending = obj.version
          obj.replica_update(self)
          save!

          Ygg::Core::ReplicaNotify.find_or_create_by!(obj: obj, notify_obj: obj, version_needed: obj.version, identifier: 'DEFAULT_NOTIFICATION')
        end

      when 'DESTROY_PENDING'
        change_state!('DESTROYING')
        self.version_pending = obj.version
        obj.replica_destroy(self)
        save!

        Ygg::Core::ReplicaNotify.find_or_create_by!(obj: obj, notify_obj: obj, version_needed: obj.version, identifier: 'DEFAULT_NOTIFICATION')
      end

      # Maybe no replication is actually made pending, this we trigger notification immediately
      Ygg::Core::ReplicaNotify.check_for(obj: obj)
    end
  end

  def self.process_all!
    # Do not lock here. Proper locking will be done in #process! in short-lived transactions

    where(state: 'IDLE').where('version_done < version_needed').each do |replica|
      replica.process!
    end

    where(state: [ 'UNKNOWN', 'FAILURE', 'DESTROY_PENDING' ]).each do |replica|
      replica.process!
    end
  end

  def self.process_all_async!(**args)
    begin
      RailsAmqp.interface.publish(exchange: 'ygg.core.replica.process-request', payload: args)
    rescue AM::AMQP::Client::MsgPublishFailure
    end
  end

  STATES = [
    'UNKNOWN',
    'IDLE',
    'UPDATING',
    'DESTROYING',
    'DESTROY_PENDING',
    'UPDATING_THEN_DESTROY',
    'DESTROYING_THEN_CREATE',
    'FAILURE',
    'DESTROYED',
  ].freeze

  def change_state!(new_state)
    raise "Invalid State #{new_state}" if !STATES.include?(new_state)

    self.state = new_state
  end

end

end
end
