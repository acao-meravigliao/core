#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ml

class Msg < Ygg::PublicModel
  self.table_name = 'ml.msgs'

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, default: nil, default_function: "gen_random_uuid()", null: false}],
    [ :must_have_column, {name: "message", type: :text, default: nil, null: false}],
    [ :must_have_column, {name: "abstract", type: :string, default: nil, null: false}],
    [ :must_have_column, {name: "created_at", type: :datetime, default: nil, null: false}],
    [ :must_have_column, {name: "delivery_started_at", type: :datetime, default: nil, null: true}],
    [ :must_have_column, {name: "sender_id", type: :integer, default: nil, limit: 4, null: true}],
    [ :must_have_column, {name: "email_message_id", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_column, {name: "status", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_column, {name: "person_id", type: :integer, default: nil, limit: 4, null: true}],
    [ :must_have_column, {name: "type", type: :string, default: nil, limit: 64, null: false}],
    [ :must_have_column, {name: "updated_at", type: :datetime, default: nil, null: false}],
    [ :must_have_column, {name: "delivery_last_attempt_at", type: :datetime, default: nil, null: true}],
    [ :must_have_column, {name: "recipient_id", type: :integer, default: nil, limit: 4, null: false}],
    [ :must_have_column, {name: "delivery_successful_at", type: :datetime, default: nil, null: true}],
    [ :must_have_column, {name: "receipt_code", type: :string, default: nil, limit: 64, null: true}],
    [ :must_have_column, {name: "email_mdn_request", type: :boolean, default: false, null: false}],
    [ :must_have_column, {name: "email_data_response", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "skebby_order", type: :string, default: nil, null: true}],
    [ :must_have_column, {name: "submitted_at", type: :datetime, default: nil, null: true}],

    [ :must_have_index, {columns: ["email_message_id"], unique: true}],
    [ :must_have_index, {columns: ["person_id"], unique: false}],
    [ :must_have_index, {columns: ["recipient_id"], unique: false}],
    [ :must_have_index, {columns: ["sender_id"], unique: false}],

    [ :must_have_fk, {to_table: "core_people", column: "person_id", primary_key: "id", on_delete: nil, on_update: nil}],
    [ :must_have_fk, {to_table: "ml.addresses", column: "recipient_id", primary_key: "id", on_delete: nil, on_update: nil}],
    [ :must_have_fk, {to_table: "ml.senders", column: "sender_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  belongs_to :sender,
           class_name: '::Ygg::Ml::Sender'

  belongs_to :recipient,
             class_name: '::Ygg::Ml::Address'

  belongs_to :person,
             class_name: '::Ygg::Core::Person',
             optional: true

  has_many :msg_objects,
           class_name: '::Ygg::Ml::Msg::Object',
           dependent: :destroy,
           autosave: true,
           embedded: true

#  has_many :objects,
#           through: :msg_objects

  has_many :msg_lists,
           class_name: '::Ygg::Ml::Msg::List',
           dependent: :destroy,
           autosave: true,
           embedded: true

  has_many :lists,
           class_name: '::Ygg::Ml::List',
           through: :msg_lists

  has_many :events,
           class_name: '::Ygg::Ml::Msg::Event'

  # Email only
  has_many :bounces,
           class_name: 'Ygg::Ml::Bounce'

  validates :message, presence: true

  before_create do
    self.created_at = Time.now
  end

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  def sent!
    case status
    when 'PENDING',
         'FAILED_RETRY'
      self.status = 'SENT'
      self.submitted_at = Time.now
      events.create(at: Time.now, event: 'SUCCESS')
    else
      raise "Unexpected #{__method__} in status #{status}"
    end
  end

  def sending_attempted!
    events.create(at: Time.now, event: 'ATTEMPT')

    self.delivery_started_at ||= Time.now
    self.delivery_last_attempt_at = Time.now
    save!
  end

  def sending_failed!(reason: nil)
    events.create(at: Time.now, event: 'ATTEMPT_FAILED')

    self.status_reason = reason
    self.status = 'FAILED_RETRY'
    self.retry_at = Time.now + 1.hour
    save!
  end

  def sending_permanent_failure!(reason: nil)
    events.create(at: Time.now, event: 'FAILED')

    self.status_reason = reason
    self.status = 'FAILED'
    save!
  end

  def delivered!(time: Time.now)
    events.create(at: Time.now, event: 'DELIVERED')

    self.status = 'DELIVERED'
    self.delivery_successful_at = time
    save!
  end

  def assume_delivered!
    events.create(at: Time.now, event: 'DELIVERED')

    self.status = 'ASSUMED_DELIVERED'
    self.delivery_successful_at = Time.now
    save!
  end

  def finalize!
    raise "Message already finalized" if status != 'NEW'
    self.status = 'PENDING'
  end

  def resend!
    transaction do
      new_msg = self.class.create(
        message: message,
        abstract: abstract,
        sender: sender,
        status: 'PENDING',
        person: person,
        type: type,
        recipient: recipient,
      )
    end

    self.class.queue_flush!
  end

  class TemplateNotFound < StandardError ; end

  def self.notify(**args)
    Ygg::Ml::Msg::Email.notify(**args)
  end

  def self.notify_by_sms(**args)
    Ygg::Ml::Msg::Sms.notify(**args)
  end

  def self.queue_flush!
    where(status: 'SENT').each do |msg|
      transaction do
        msg.check_status!
      end
    end

    where(status: [ 'NEW', 'PENDING', 'FAILED_RETRY' ]).each do |msg|
      transaction do
        if !msg.retry_at || Time.new > msg.retry_at
          msg.send!
        end
      end
    end
  end

  def check_status!
  end

  def send!
  end
end

end
end
