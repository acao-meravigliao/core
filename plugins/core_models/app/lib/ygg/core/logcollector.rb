#
# Copyright (C) 2008-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

module Logcollector
  extend ActiveSupport::Concern

  included do
    after_save { logcol_mark_event(:save) }
    after_create { logcol_mark_event(:create) }
    after_update { logcol_mark_event(:update) }
    after_destroy { logcol_mark_event(:destroy) }
  end

  Ygg::Core::Transaction.before_commit do |t|
    logcol_before_ygg_commit(t)
  end

  def logcol_mark_event(event)
    xact = Ygg::Core::Transaction.current
    return if !xact

    touched_objects = xact.store[:log_collector_touched_objects] ||= {}

    obj_key = "#{self.class.name}-#{id}"
    ce = touched_objects[obj_key] ? touched_objects[obj_key][:event] : event

    case event
    when :create
      ce = event unless [ :destroy ].include?(ce)
    when :update, :save
      ce = event unless [ :create, :save, :update, :destroy ].include?(ce)
    when :destroy
      ce = :destroy
    end

    touched_objects[obj_key] = { obj: self, event: ce }
  end

  def self.logcol_before_ygg_commit(transaction)
    xact = Ygg::Core::Transaction.current

    # Workaround for development mode. When observers should be unloaded they have no chance
    # to unregister with Ygg::Core::Transaction and their before_commit is called once for each observer
    # FIXME!
    return if xact.store[:logged]
    xact.store[:logged] = true

    if xact.params[:aaa_context]
      xact.params[:person] = xact.params[:aaa_context].auth_person
      xact.params[:session_id] = xact.params[:aaa_context].id
    end

    log_entry = Ygg::Core::LogEntry.create(
      person: xact.params[:person],
      transaction_id: transaction.id,
      description: xact.descr,
      extra_info: xact.params[:extra_info],
      http_session_id: xact.params[:session_id]
    )

    if xact.store[:log_collector_touched_objects]
      xact.store[:log_collector_touched_objects].each do |obj_key, event|
        if event[:obj].respond_to?(:log_detail!)
          event[:obj].log_detail!(
             log_entry: log_entry,
             operation: event[:event],
          )
        end
      end
    end
  end
end

end
end
