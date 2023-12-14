#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Taask < Ygg::PublicModel
  self.table_name = 'core.tasks'

  self.porn_migration += [
    [ :must_have_column, { name: 'id', type: :integer, null: false } ],
    [ :must_have_column, { name: 'created_at', type: :datetime } ],
    [ :must_have_column, { name: 'expected_completion', type: :datetime } ],
    [ :must_have_column, { name: 'completed_at', type: :datetime } ],
    [ :must_have_column, { name: 'status', type: :string, null: false, limit: 32 } ],
    [ :must_have_column, { name: 'description', type: :string } ],
    [ :must_have_column, { name: 'depends_on_id', type: :integer } ],
    [ :must_have_column, { name: 'agent', type: :string, limit: 64 } ],
    [ :must_have_column, { name: 'operation', type: :string } ],
    [ :must_have_column, { name: 'request_data', type: :json } ],
    [ :must_have_column, { name: 'result_data', type: :json } ],
    [ :must_have_column, { name: 'log', type: :text, null: false } ],
    [ :must_have_column, { name: 'deferred_to', type: :datetime } ],
    [ :must_have_column, { name: 'percent', type: :float } ],
    [ :must_have_column, { name: 'deadline', type: :datetime } ],
    [ :must_have_column, { name: 'updated_at', type: :datetime, } ],
    [ :must_have_column, { name: 'awaited_event', type: :string, limit: 32 } ],
    [ :must_have_column, { name: 'scheduler', type: :string, limit: 32 } ],
    [ :must_have_column, { name: 'obj_type', type: :string, } ],
    [ :must_have_column, { name: 'obj_id', type: :integer } ],
  ]

  belongs_to :depends_on,
             class_name: '::Ygg::Core::Taask',
             optional: true

  has_many :dependencies,
           class_name: '::Ygg::Core::Taask',
           foreign_key: :depends_on_id,
           dependent: :destroy

  has_many :notifies,
           class_name: '::Ygg::Core::Taask::Notify',
           foreign_key: 'task_id',
           embedded: true,
           autosave: true,
           dependent: :destroy,
           inverse_of: :task # Rails bug https://github.com/rails/rails/issues/25198

  belongs_to :obj,
             polymorphic: true,
             optional: true


  # No attribute is sensitive for authorization
  idxc_cached
  self.idxc_sensitive_attributes = []

  def result_data_changed!
    result_data_will_change!
  end

  class LifeCycleController
    include ActiveRest::Controller
    ar_controller_for Klass
    self.ar_authorization_required = false

    view :event do
      empty!
      attribute(:status) { show! }
      attribute(:percent) { show! }
      attribute(:updated_at) { show! }
    end
  end

  class NotDeletable < StandardError ; end

  after_initialize do
    if new_record?
      self.created_at = Time.now
      self.status = dependencies.any? ? 'WAIT_DEPENDENCY' : 'PENDING'
      self.scheduler ||= 'hel'
      self.log ||= ''
    end
  end

  after_commit on: :create do
    notify_queue! if Rails.application.config.core.task_notify_enabled
  end

  before_destroy do
    if status != 'COMPLETED' && status != 'FAILED' && status != 'CANCELED' && status != 'INCONSISTENT'
      raise NotDeletable, 'This task is still being processed'
    end
  end

  def notify_queue!
    begin
      RailsAmqp.interface.publish(exchange: 'ygg.task.wakeup', payload: { task_id: self.id })
    rescue AM::AMQP::Client::MsgPublishFailure
    end
  end

  def self.roots
    where(depends_on_id: nil)
  end

  def self.finals
    # INCONSISTENT requires special handling
    where(status: [ 'COMPLETED', 'FAILED', 'CANCELED' ])
  end

  def self.not_finals
    # INCONSISTENT requires special handling
    where.not(status: [ 'COMPLETED', 'FAILED', 'CANCELED' ])
  end

#  def service_label
#    return nil if !obj
#
#    svcname = obj.respond_to?(:label) ? obj.label : (obj.respond_to?(:name) ? obj.name : obj.to_s)
#
#    clsname = obj.class.model_name.human
#    clsname + ' ' + svcname
#  end

  def has_pending_dependencies?
    dependencies.reload.not_finals.any?
  end

  ##########################################

  def child_failed!(child)
    case status
    when 'WAIT_DEPENDENCY', 'FAILED_RETRY', 'CANCELED'
      change_status!('FAILED')
      save!

      dependencies.each do |dep|
        next if dep == child
        dep.parent_failed!
        dep.save!
      end

      if depends_on
        depends_on.child_failed!(self)
        depends_on.save!
      end

      notifies.each do |notify|
        notify.obj.task_failed!(self) if notify.obj
      end

    when 'FAILED'
      change_status!('FAILED')
    else
      raise InvalidTransition.new(status, __method__)
    end
  end

  def child_canceled!(child)
    case status
    when 'WAIT_DEPENDENCY', 'FAILED_RETRY'
      change_status!('FAILED')
      save!

      dependencies.each do |dep|
        next if dep == child
        dep.parent_failed!
        dep.save!
      end
      if depends_on
        depends_on.child_failed!(self)
        depends_on.save!
      end

      notifies.each do |notify|
        notify.obj.task_failed!(self) if notify.obj
      end

    when 'CANCELED'
    when 'FAILED'
    else
      raise InvalidTransition.new(status, __method__)
    end
  end

  def child_completed!
    case status
    when 'WAIT_DEPENDENCY'
      if !has_pending_dependencies?
        change_status!('PENDING')
        process!
      end
    when 'FAILED_RETRY'
      change_status!('FAILED_RETRY')
    when 'CANCELED'
      change_status!('CANCELED')
    when 'FAILED'
      change_status!('FAILED')
    else
      raise InvalidTransition.new(status, __method__)
    end
  end

  def defer!(defer_to: nil, retry_after: 5.minutes)
    self.class.transaction do
      case status
      when 'PENDING', 'FAILED_RETRY'
        self.deferred_to = defer_to || Time.now + retry_after
        change_status!('DEFERRED')
      else
        raise InvalidTransition.new(status, __method__)
      end
    end
  end

  def wait_for_event!(event)
    self.class.transaction do
      case status
      when 'PENDING'
        self.awaited_event = event
        change_status!('WAIT_FOR_EVENT')
      else
        raise InvalidTransition.new(status, __method__)
      end
    end
  end

  def event!(event)
    self.class.transaction do
      if status == 'WAIT_FOR_EVENT' && event == awaited_event
        self.awaited_event = nil

        if operation == 'WAIT_FOR_EVENT'
          completed!
        else
          change_status!('PENDING')
        end

        process!
      end
    end
  end

  def request_sent!
    case status
    when 'WAIT_DEPENDENCY'
    when 'WAIT_FOR_EVENT'
    when 'DEFERRED'
    when 'PENDING'
      change_status!('REQUEST_SENT')
    when 'REQUEST_SENT'
    when 'IN_PROGRESS'
    when 'FAILED_RETRY'
    when 'CANCELED'
    when 'FAILED'
    when 'COMPLETED'
    when 'INCONSISTENT'
    end
  end

  def started!
    self.class.transaction do
      case status
      # Transition started on PENDING is received only when the task is not originated by Hel
      when 'PENDING', 'REQUEST_SENT'
        change_status!('IN_PROGRESS')
      when 'IN_PROGRESS', 'FAILED_RETRY'
        # Happens when the agent dies after sending started
        # XXX WARN
        change_status!('IN_PROGRESS')
      else
        raise InvalidTransition.new(status, __method__)
      end
    end

    save!
  end

  def append_log!(text, append_lf: false)
    self.log += text
    self.log += "\n" if append_lf
  end

  def update_percent!(percent)
    self.percent = percent
  end

  def update_result_data!(data)
    if result_data && !data.kind_of?(Hash)
      raise "Impossible to update data with non-hash data"
    end

    if result_data
      result_data.merge!(data)
    else
      self.result_data = data
    end

    result_data_changed!
  end

  def completed!
    self.class.transaction do
      case status
      when 'PENDING', 'REQUEST_SENT', 'IN_PROGRESS', 'WAIT_FOR_EVENT'
        self.completed_at = Time.now
        result_data_changed!

        change_status!('COMPLETED')
        save!

        if depends_on
          depends_on.child_completed!
        end

        notifies.each do |notify|
          notify.obj.task_completed!(self) if notify.obj
        end
      when 'COMPLETED'
        # WARN ???
        change_status!('COMPLETED')
      else
        raise InvalidTransition.new(status, __method__)
      end
    end

    save!
  end

  def retry!
    self.class.transaction do
      case status
      when 'FAILED_RETRY'
        change_status!('PENDING')
        process!
      else
        raise InvalidTransition.new(status, __method__)
      end
    end

    save!
  end

  def continue!
    self.class.transaction do
      case status
      when 'DEFERRED'
        change_status!('PENDING')
        process!
      else
        raise InvalidTransition.new(status, __method__)
      end
    end

    save!
  end

  def cancel!
    self.class.transaction do
      case status
      when 'PENDING', 'WAIT_DEPENDENCY', 'WAIT_FOR_EVENT', 'DEFERRED', 'FAILED_RETRY'
        change_status!('CANCELED')
        save!

        dependencies.each do |dep|
          dep.parent_canceled!
        end

        if depends_on
          depends_on.child_canceled!(self)
        end

        notifies.each do |notify|
          notify.obj.task_canceled!(self) if notify.obj
        end
      when 'REQUEST_SENT', 'IN_PROGRESS'
        # Oops, too late. Maybe we could implement cancel during provisioning. For now we continue regardless.
      else
        raise InvalidTransition.new(status, __method__)
      end
    end

    save!
  end

  def parent_failed!
    case status
    when 'PENDING', 'WAIT_DEPENDENCY', 'WAIT_FOR_EVENT', 'DEFERRED'
      cancel!
    when 'REQUEST_SENT', 'IN_PROGRESS', 'FAILED_RETRY', 'CANCELED', 'FAILED', 'COMPLETED', 'INCONSISTENT'
    end

    save!
  end

  def parent_canceled!
    case status
    when 'PENDING', 'WAIT_DEPENDENCY', 'WAIT_FOR_EVENT', 'DEFERRED'
      cancel!
    when 'REQUEST_SENT', 'IN_PROGRESS', 'FAILED_RETRY', 'CANCELED', 'FAILED', 'COMPLETED', 'INCONSISTENT'
    end

    save!
  end

  def temporary_failure!(defer_to: nil, retry_after: 5.minutes)
    case status
    # FAILED_RETRY => FAILED_RETRY is a workaround for agent being respawned
    when 'DEFERRED', 'PENDING', 'REQUEST_SENT', 'IN_PROGRESS', 'FAILED_RETRY'
      self.deferred_to = defer_to || Time.now + retry_after
      change_status!('FAILED_RETRY')
    else
      raise InvalidTransition.new(status, __method__)
    end

    save!
  end

  def permanent_failure!
    self.class.transaction do
      case status
      when 'DEFERRED', 'PENDING', 'REQUEST_SENT', 'IN_PROGRESS', 'FAILED_RETRY'
        change_status!('FAILED')
        save!

        if depends_on
          depends_on.child_failed!(self)
          depends_on.save!
        end

        notifies.each do |notify|
          notify.obj.task_failed!(self) if notify.obj
        end
      else
        raise InvalidTransition.new(status, __method__)
      end
    end

    save!
  end

  #################################################################

#  protected

  def process!(force_failed: false)
    return if scheduler != 'hel'

    case status
    when 'WAIT_DEPENDENCY'
    when 'WAIT_FOR_EVENT'
    when 'DEFERRED'
      if deferred_to < Time.now
        change_status!('PENDING')
        process!(force_failed: force_failed)
      end
    when 'PENDING'
      execute!
    when 'REQUEST_SENT'
    when 'IN_PROGRESS'
    when 'FAILED_RETRY'
      if Time.now > deferred_to
        if deadline && Time.now > deadline
          permanent_failure!
        else
          retry!
        end
      end
    when 'CANCELED'
    when 'FAILED'
    when 'COMPLETED'
    when 'INCONSISTENT'
    end

    save!
  end

  def execute!
    if deadline && Time.now > deadline
      permanent_failure!
    else
      notifies.each do |notify|
        notify.obj.task_start_execution!(self) if notify.obj
      end

      # if task_start_execution did something to the status
      return if status != 'PENDING'

      if agent
        start_via_agent
      else
        case operation
        when 'NOP', nil
           completed!
        when 'WAIT_FOR_EVENT'
          wait_for_event!(request_data)
        when 'NONAGENT_PROCESSING'
          change_status!('IN_PROGRESS')
        else
          permanent_failure!
        end
      end
    end
  end

  def start_via_agent
    append_log!("\n------------------------ Sending....")

    req = {
      created_at: created_at,
      updated_at: updated_at,
      expected_completion: expected_completion,
      deadline: deadline,
      description: description,
      agent: agent,
      operation: operation,
      request_data: request_data,
    }

    headers = {
      type: 'START',
      reply_to: 'ygg.task.messages',
      correlation_id: id,
    }

    headers[:expiration] = ((deadline - Time.now) * 1000).to_i if deadline

    begin
      RailsAmqp.interface.publish(
        exchange: agent,
        payload: req,
        persistent: true,
        headers: headers,
      )
    rescue StandardError => e
      append_log!("Message sending error: #{e}")
      temporary_failure!
    else
      request_sent!
    end
  end


  def self.queue_run!(quick: false, force_failed: false)
    # Ensure the rows are locked as there will be race conditions with responses going to hel_together

    transaction do
      where(status: 'PENDING', scheduler: 'hel').limit(500).lock(true).each do |task|
        task.process!
        task.save!
      end
    end

    if !quick
      transaction do
        where(status: 'DEFERRED').where('deferred_to < ?', Time.now).where(scheduler: 'hel').lock(true).each do |task|
          task.process!
          task.save!
        end
      end

      transaction do
        where(status: 'FAILED_RETRY').where(scheduler: 'hel').limit(500).lock(true).each do |task|
          task.process!(force_failed: force_failed)
          task.save!
        end
      end
    end
  end

  def self.queue_run_async!(**args)
    begin
      RailsAmqp.interface.publish(exchange: 'ygg.task.wakeup', payload: args)
    rescue AM::AMQP::Client::MsgPublishFailure
    end
  end

  def self.queue_trim!(max_age: 1.hour)
    roots.finals.where('completed_at < ?', Time.now - max_age).each do |pr|
      pr.destroy if !pr.has_pending_dependencies?
    end
  end

  def self.queue_cleanup!(max_age: 1.hour)
    queue_trim!(max_age: max_age)

    roots.where(status: 'WAIT_DEPENDENCY').each do |task|
      if !task.has_pending_dependencies?
        task.change_status!('PENDING')
        task.process!
      end
    end
  end

  def summary
    id.to_s
  end

  class InvalidTransition < StandardError
    def initialize(state, event)
      super("Received unexpected event '#{event}' in state '#{state}'")
    end
  end

  STATES = [
    'WAIT_DEPENDENCY',
    'WAIT_FOR_EVENT',
    'DEFERRED',
    'PENDING',
    'REQUEST_SENT',
    'IN_PROGRESS',
    'FAILED_RETRY',
    'CANCELED',     # FINAL
    'FAILED',       # FINAL
    'COMPLETED',    # FINAL
    'INCONSISTENT', # FINAL
  ].freeze

  def change_status!(new_status)
    raise "Invalid State #{new_status}" if !STATES.include?(new_status)

    self.status = new_status
  end

end

end
end
