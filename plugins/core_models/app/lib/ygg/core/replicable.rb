#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

# When a versionable object is changed in a way that increments the version all the needed replicas will be checked
# If any sensitive attribute for that replica has been changed then the replica's version_needed will be set to current object's version
#
# Asynchronously replicas_go! is called later

module Ygg
module Core

module Replicable
  extend ActiveSupport::Concern

  include Ygg::Core::ReplicaNotifiable

  included do
    before_save do
      # If this is a new record wait in after_create for the id to be assigned
      if !new_record? && Rails.application.config.core.replicas_enabled
        replicas_precess_changes!
      end
    end

    after_create do
      if Rails.application.config.core.replicas_enabled
        reps_needed = replicas_needed

        reps_needed.each do |rep_identifier, rep_needed|
          rep_new = replicas.build(
            identifier: rep_identifier,
            version_pending: 0,
            version_done: 0,
            version_needed: version,
            state: 'UNKNOWN',
            function: rep_needed[:function],
            descr: rep_needed[:descr],
            data: rep_needed[:data],
          )

          rep_new.save!

          @replicas_process_pending = true
        end
      end
    end

    after_commit do
      if Rails.application.config.core.replicas_enabled &&
         Rails.application.config.core.replicas_notify_enabled &&
         @replicas_process_pending

        @replicas_process_pending = false

        xact = Ygg::Core::Transaction.current
        if xact
          xact.store[:replicas_process_pending] = true
        else
          Ygg::Core::Replica.process_all_async!
        end
      end
    end

    replicas_completed do
      if condemned
        destroy!
      else
        lc_mark_event(:update)
        lc_trigger_publish!
      end
    end

    has_many :replicas,
             class_name: 'Ygg::Core::Replica',
             as: :obj,
             autosave: true

    has_many :replica_notifications,
             class_name: 'Ygg::Core::ReplicaNotify',
             as: :obj

    has_many :replica_notifications_as_dest,
             class_name: 'Ygg::Core::ReplicaNotify',
             as: :notify_obj
  end

  Ygg::Core::Transaction.after_commit do |t|
    replicas_before_ygg_commit(t)
  end

  def request_destroy
    self.condemned = true
    save!

    true
  end

  def self.replicas_before_ygg_commit(transaction)
    xact = Ygg::Core::Transaction.current
    return if !xact

    if xact.store[:replicas_process_pending] && Rails.application.config.core.replicas_notify_enabled
      Ygg::Core::Replica.process_all_async!
    end
  end

  def replicas_precess_changes!(force: false)
    reps_current = replicas
    reps_needed = replicas_needed

    reps_current.each do |rep_current|
      rep_needed = reps_needed.delete(rep_current.identifier)

      if force || (rep_needed && replication_will_be_needed?(rep_needed))
        rep_current.version_needed = version
        @replicas_process_pending = true
      end

      if condemned || !rep_needed
        # This replica should be destroyed soon or later

        case rep_current.state
        when 'UNKNOWN', 'IDLE', 'FAILURE'
          rep_current.change_state!('DESTROY_PENDING')
        when 'UPDATING'
          rep_current.change_state!('UPDATING_THEN_DESTROY')
        when 'DESTROYING_THEN_CREATE'
          rep_current.change_state!('DESTROYING')
        end
      else
        # This replica should be there, and maybe updated

        # Update replica data if needed
        rep_current.function = rep_needed[:function]
        rep_current.descr = rep_needed[:descr]
        rep_current.data = rep_needed[:data]

        case rep_current.state
        when 'DESTROY_PENDING', 'DESTROYED'
          rep_current.change_state!('IDLE')
        when 'UPDATING_THEN_DESTROY'
          rep_current.change_state!('UPDATING')
        when 'DESTROYING'
          rep_current.change_state!('DESTROYING_THEN_CREATE')
        end
      end

      if rep_current.changed?
        rep_current.save!
        @replicas_process_pending = true
      end
    end

    # Now reps_needed contains not yet created
    reps_needed.each do |rep_identifier, rep_needed|
      rep_new = replicas.build(
        identifier: rep_identifier,
        version_pending: 0,
        version_done: 0,
        version_needed: version,
        state: 'UNKNOWN',
        function: rep_needed[:function],
        descr: rep_needed[:descr],
        data: rep_needed[:data],
      )

      rep_new.save!

      @replicas_process_pending = true
    end
  end

  def replicas_okay?
    replicas.all? { |x| (x.state == 'IDLE' && x.version_done >= x.version_needed) || x.state == 'DESTROYED' }
  end

  def replicas_state
    if replicas_okay?
      return 'READY'
    elsif replicas.any? { |x| x.state == 'FAILURE' }
      return 'FAILURE'
    elsif replicas.all? { |x| [ 'UPDATING', 'DESTROYING', 'UPDATING_THEN_DESTROY', 'DESTROYING_THEN_CREATE' ].include?(x.state) }
      return 'IN_PROGRESS'
    else
      return 'PENDING'
    end
  end

  def replicas_req_notify(notify_obj:, version_needed: version, **args)
    Ygg::Core::ReplicaNotify.create!(obj: self, notify_obj: notify_obj, version_needed: version_needed, **args)
  end

  def replicas_force!
    transaction do
      self.version += 1
      replicas_precess_changes!(force: true)
      save!
    end

    Ygg::Core::Replica.process_all_async!
  end

  def replication_will_be_needed?(rep)
    if rep[:sensitive_attributes]
      (rep[:sensitive_attributes].map(&:to_s) & deep_changes.keys).any?
    else
      (deep_changes.keys - (rep[:insensitive_attributes] || []).map(&:to_s)).any?
    end
  end
end

end
end
