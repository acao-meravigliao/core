#
# Copyright (C) 2017-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ml

class Bounce < Ygg::PublicModel
  self.table_name = 'ml.msg_bounces'
  self.inheritance_column = false

  belongs_to :msg,
             class_name: '::Ygg::Ml::Msg::Email'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  def self.report(rcpt:, from:, body:)
    Ygg::Core::Transaction.new('Bounce reported') do
      bounce_attrs = {
        sender: from,
        body: body,
        received_at: Time.now,
      }

      match = /^(?<msgid>.*)@(?<domain>.*)/.match(rcpt)
      if !match
        logger.warn "#{self.class}: unable to parse rcpt '#{rcpt}'"
        trim_and_create(bounce_attrs)
        return
      end

      message_id = match[:msgid]

      msg = Ygg::Ml::Msg::Email.find_by(email_message_id: message_id)
      if !msg
        logger.warn "#{self.class}: cannot find message with original message-id '#{message_id}'"
        trim_and_create(bounce_attrs)
        return
      end

      bounce_attrs.merge!(
        msg: msg,
      )

      m = Mail.new(body)
      ct = m.header[:content_type]

      if ct && ct.main_type == 'multipart' && ct.sub_type == 'report' && ct.parameters['report-type']
        bounce_attrs[:type] = ct.parameters['report-type']

        case ct.parameters['report-type']
        when 'delivery-status'
          handle_dsn(m: m, bounce_attrs: bounce_attrs)

        when 'disposition-notification'
          handle_mdn(m: m, bounce_attrs: bounce_attrs)

        else
          trim_and_create(bounce_attrs)
        end
      else
        bounce_attrs[:type] = ct.to_s
        trim_and_create(bounce_attrs)
      end
    end

  rescue StandardError => e
    logger.warn "Error handling bounce: #{e}\n#{e.backtrace.join("\n")}"
    Airbrake.notify(e)
  end

  def self.trim_and_create(attrs)
    attrs = attrs.dup

    attrs.each do |attr_name,attr|
      col = Ygg::Ml::Bounce.columns_hash[attr_name.to_s]
      attrs[attr_name] = attr[0..col.limit] if attr && col && col.type == :string && col.limit
    end

    bounce = Ygg::Ml::Bounce.create(attrs)

    bounce.msg.bounce_received(bounce) if bounce.msg
  end

  def self.handle_dsn(m:, bounce_attrs:)
    ds = m.parts.find { |x| x.main_type == 'message' && x.sub_type == 'delivery-status' }

    if !ds
      logger.warn "Missing message/delivery-status part from DSN"
      trim_and_create(bounce_attrs)
      return
    end

    parts = ds.body.to_s.split(/\n\n|\r\n\r\n/)

    if parts.count == 0
      logger.warn "Missing message/delivery-status per-message part from DSN"
      trim_and_create(bounce_attrs)
      return
    end

    per_msg = Mail::Header.new(parts[0])

    bounce_attrs.merge!(
      reporting_mta: per_msg[:reporting_mta] ? per_msg[:reporting_mta].to_s : nil,
      rem_arrival_date: per_msg[:arrival_date] ? Time.parse(per_msg[:arrival_date].to_s) : nil,
      rem_postfix_queue_id: per_msg[:'x-postfix-queue-id'] ? per_msg[:'x-postfix-queue-id'].to_s : nil,
      rem_postfix_sender: per_msg[:'x-postfix-sender'] ? per_msg[:'x-postfix-sender'].to_s : nil,
    )

    parts[1..-1].each do |per_rec_part|
      per_rec = Mail::Header.new(per_rec_part)

      recipient = nil

      if per_rec[:original_recipient]
        recipient ||= msg.rcpts.find_by(addr: per_rec[:original_recipient].to_s.split(';')[1].strip)
      end

      if per_rec[:final_recipient]
        recipient ||= msg.rcpts.find_by(addr: per_rec[:final_recipient].to_s.split(';')[1].strip)
      end

      if recipient && per_rec[:action]
        if per_rec[:action].to_s == 'failed'
          recipient.bounce_received!
          recipient.save!
        end
      end

      attrs = bounce_attrs.merge(
        action: per_rec[:action] ? per_rec[:action].to_s.downcase : nil,
        diagnostic_code: per_rec[:diagnostic_code] ? per_rec[:diagnostic_code].to_s : nil,
      )

      if per_rec[:status]
        match = /^(?<status>[0-9.]+) *(\((?<comment>.*)\))?$/.match(per_rec[:status].to_s)
        attrs[:status] = match[:status]
        attrs[:status_comment] = match[:comment]
      end

      if per_rec[:original_recipient]
        match = /^(?<type>[^;]*); *(?<addr>.*)$/.match(per_rec[:original_recipient].to_s)
        if !match
          logger.warn "Cannot parse original_recipient from '#{per_rec[:original_recipient].to_s}'"
        elsif match[:type].downcase != 'rfc822'
          logger.warn "Cannot understand original recipient type '#{match[:type]}', only rfc822 is supported"
        else
          attrs[:original_recipient_type] = match[:type]
          attrs[:original_recipient] = match[:addr]
        end
      end

      if per_rec[:final_recipient]
        match = /^(?<type>[^;]*); *(?<addr>.*)$/.match(per_rec[:final_recipient].to_s)
        if !match || match[:type].downcase != 'rfc822'
          logger.warn "Cannot understand final recipient type #{match[:type]}"
        else
          attrs[:final_recipient_type] = match[:type]
          attrs[:final_recipient] = match[:addr]
        end
      end

      attrs.each do |attr_name,attr|
        col = Ygg::Ml::Bounce.columns_hash[attr_name.to_s]
        attrs[attr_name] = attr[0..col.limit] if attr && col && col.type == :string && col.limit
      end

      trim_and_create(attrs)
    end
  end

  def self.handle_mdn(m:, bounce_attrs:)
    mdn = m.parts.find { |x| x.main_type == 'message' && x.sub_type == 'disposition-notification' }

    if !mdn
      logger.warn "Missing message/disposition-notification part from MDN"
      trim_and_create(bounce_attrs)
      return
    end

    mdn_headers = Mail::Header.new(mdn.body.to_s)

    bounce_attrs.merge!(
      reporting_ua: mdn_headers[:reporting_ua] ? mdn_headers[:reporting_ua].to_s : nil,
      disposition: mdn_headers[:disposition] ? mdn_headers[:disposition].to_s : nil,
      disposition_error: mdn_headers[:error] ? mdn_headers[:error].to_s : nil,
    )

    if mdn_headers[:original_recipient]
      match = /^(?<type>[^;]*); *(?<addr>.*)$/.match(mdn_headers[:original_recipient].to_s)
      if !match || match[:type].downcase != 'rfc822'
        logger.warn "Cannot understand original recipient type #{match[:type]}"
      else
        bounce_attrs[:original_recipient_type] = match[:type]
        bounce_attrs[:original_recipient] = match[:addr]
      end
    end

    if mdn_headers[:final_recipient]
      match = /^(?<type>[^;]*); *(?<addr>.*)$/.match(mdn_headers[:final_recipient].to_s)
      if !match || match[:type].downcase != 'rfc822'
        logger.warn "Cannot understand final recipient type #{match[:type]}"
      else
        bounce_attrs[:final_recipient_type] = match[:type]
        bounce_attrs[:final_recipient] = match[:addr]
      end
    end

    trim_and_create(bounce_attrs)
  end

end

end
end
