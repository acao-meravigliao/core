#
# Copyright (C) 2008-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

module Lifecycle
  extend ActiveSupport::Concern

  included do
    class_attribute :lc_sensitive_attributes
    class_attribute :lc_insensitive_attributes
    self.lc_insensitive_attributes = [
      :created_at,
      :updated_at,
    ]

    before_create do
      lc_mark_event(:create) if Rails.application.config.core.lc_enabled
    end

    before_update do
      lc_mark_event(:update) if Rails.application.config.core.lc_enabled && lc_object_changed?
    end

    before_destroy do
      lc_mark_event(:destroy) if Rails.application.config.core.lc_enabled
    end

    after_commit :lc_trigger_publish!

    class << self
      prepend PrependedClassMethods
    end
  end

  module PrependedClassMethods
    def inherited(child)
      super(child)

      child.lc_sensitive_attributes = lc_sensitive_attributes.try(:deep_dup)
      child.lc_insensitive_attributes = lc_insensitive_attributes.try(:deep_dup)
    end
  end

  def lc_mark_event(event)
    @lc_events ||= {}
    @lc_events[event] = true
  end

  def lc_object_changed?
    lc_sensitive_attributes ?
      (lc_sensitive_attributes.map(&:to_s) & deep_changes.keys).any? :
      (deep_changes.keys - lc_insensitive_attributes.map(&:to_s)).any?
  end

  def lc_trigger_publish!
    return if !@lc_events

    model_name = self.class.respond_to?(:lc_class_name) ? self.class.lc_class_name : self.class.name

    msg = {
      model: model_name,
      object_id: id,
    }

    if Ygg::Core::Transaction.current
      params = Ygg::Core::Transaction.current.params

      msg[:xact_id] = Ygg::Core::Transaction.current.id

      if params[:aaa_context] && params[:aaa_context].auth_person
        msg.merge!({
          person_id: params[:aaa_context].auth_person.id,
          person_name: params[:aaa_context].auth_person.name,
          credential_id: params[:aaa_context].auth_credential.id,
        })
      end

      if params[:request_id]
        msg[:http_request_id] = Ygg::Core::Transaction.current.params[:request_id]
      end
    end

    msg[:events] = @lc_events.keys.map { |x|
      case x
      when :create ; 'C'
      when :update ; 'U'
      when :destroy ; 'D'
      end
    }.join

    begin
      RailsAmqp.interface.publish(
        exchange: Rails.application.config.core.lc_exchange,
        payload: msg,
        routing_key: model_name.underscore.pluralize.gsub('/', '.') + '.' + id.to_s,
        mandatory: false,
        persistent: false,
        headers: {
          expiration: 60000,
          type: 'LIFECYCLE_UPDATE',
        })
    rescue AM::AMQP::Client::MsgChannelOpenFailure
      raise unless Rails.application.config.core.amqp_may_fail
    end

    @lc_events = nil
  end
end

end
end
