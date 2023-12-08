#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Ml

class Msg::Sms < Ygg::Ml::Msg
  def check_status!
    if delivery_started_at < Time.now - 1.week
      sending_permanent_failure!(reason: 'Gave up due to timeout')
    end

    if !skebby_order
      sending_permanent_failure!(reason: 'Order id not present')
      return
    end

    res = Ygg::Ml::Skebby.get_sms_state(sender: sender, order_id: skebby_order)

    recipient = res[:recipients].first
    status = recipient['status']

    self.skebby_status = status

    case status
    when 'WAITING'
    when 'SENT'
    when 'WAIT4DLVR'
    when 'DLVRD'
      delivered!(time: Time.parse(recipient['delivery_date']))
    when 'TOOM4USER'
    when 'TOOM4NUM'
    when 'ERROR'
    when 'UNKNRCPT'
    when 'UNKNPFX'
    when 'INVALIDDST'
    when 'BLACKLISTED'
    when 'KO'
    when 'INVALIDCONTENTS'
      sending_permanent_failure!(reason: status)
    when 'TIMEOUT'
    when 'DEMO'
    when 'SCHEDULED'
    when 'OK'
    end

    save! if changed?

  rescue Skebby::OrderNotFound
    sending_permanent_failure!(reason: 'Order not found anymore')
  rescue Skebby::SkebbyError => e
    logger.warn "Error retrieving Skebby state: #{e}"
  end

  def send!
    transaction do
      finalize! if status == 'NEW'

      sending_attempted!

      destination_number = recipient.addr

      if Rails.application.config.ml.sms_redirect_to
        destination_number = Rails.application.config.ml.sms_redirect_to
      end

      if !Rails.application.config.ml.sms_disable
        begin
          result = Ygg::Ml::Skebby.send_sms(
            sender: sender,
            recipients: destination_number,
            text: message,
            debug: Rails.application.config.ml.sms_skebby_debug,
          )
        rescue AM::HTTP::Client::MsgRequestFailure => e
          sending_failed!(reason: e.title)
        else
          if result[:result] == 'OK'
            self.receipt_code = result[:internal_order_id]
            self.skebby_order = result[:order_id]
            sent!
          else
            sending_failed!(reason: result[:result])
            Ygg::Ml::Msg.notify(destinations: 'ADMINS', template: 'SMS_SEND_FAILED', template_context: {
              recipient: recipient.addr,
              text: message,
            })
          end

#          if result['remaining_credits'] && result['remaining_credits'].to_i < 50
#            Ygg::Ml::Msg.notify(destinations: 'ADMINS', template: 'LOW_SMS_COUNT', template_context: {
#              remaining_sms: result['remaining_sms'].to_i,
#            })
#          end
        end
      else
        self.receipt_code = "FAKE SENDING"
        sent!
      end

      save!
    end
  end

  def self.notify(sender: Rails.application.config.ml.default_sender, destinations:,
                  template:, template_context: {}, objects: [], **args)

    sender = Ygg::Ml::Sender.find_by_symbol!(sender)

    destinations = [ destinations ] if !destinations.kind_of?(Array)
    objects = [ objects ] if !objects.kind_of?(Array)

    destinations = destinations.map { |dest|
      case dest
      when Ygg::Core::Person
        dest
      when Ygg::Core::Group
        dest.people
      when String
        Ygg::Core::Group.find_by_symbol(dest).people
      end
    }.flatten

    msgs = []

    transaction do
      destinations.each do |person|

        if template
          if template.is_a?(Ygg::Ml::Template)
            tpl = template
          else
            tpl = Ygg::Ml::Template.find_by(symbol: template, language: person.preferred_language)
          end

          tpl ||= Ygg::Ml::Template.find_by(symbol: template)

          raise TemplateNotFound if !tpl
        end

        person.contacts.where(type: 'mobile').each do |contact|
          rcpt_addr = Ygg::Ml::Address.find_or_create_by(addr: Phoner::Phone.parse(contact.value, country_code: '39').to_s ) do |newaddr|
            newaddr.name = person.name
            newaddr.addr_type = 'MOBILE'
          end

          full_message = nil

          tpl_result = tpl.process(template_context.merge({
            recipient_addr: rcpt_addr.addr,
            recipient_name: rcpt_addr.name,
          }))

          msg = Ygg::Ml::Msg::Sms.new(
            sender: sender,
            recipient: rcpt_addr,
            person: person,
            msg_objects: objects.map { |x| Ygg::Ml::Msg::Object.new(object: x) },
            status: 'PENDING',
            abstract: tpl_result[:body],
            message: tpl_result[:body],
          )

          msg.save!

          msgs << msg
        end
      end
    end

    queue_flush!

    msgs
  end

end

end
end
