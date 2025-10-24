#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'dkim'

require 'am/smtp/client'

module Ygg
module Ml

class Msg::Email < Ygg::Ml::Msg
  validates :abstract, presence: true

  after_initialize do
    if new_record?
      self.email_message_id = SecureRandom.hex(16)
    end
  end

  before_validation do
  end

  def to_mail
    ::Mail.new(message)
  end

  def set_from_mail(mail)
    write_attribute(:message, mail.encoded)
    write_attribute(:abstract, mail.subject || mail.body.to_s[0..64])
  end

  def finalize!
    raise "Message already finalized" if status != 'NEW'

    final_mail = ::Mail.new(message)
    final_mail['Message-ID'] = email_message_id + '@' + sender.email_bounces_domain
    final_mail['Return-Path'] = email_message_id + '@' + sender.email_bounces_domain

    if email_mdn_request
      final_mail['Disposition-Notification-To'] = email_message_id + '@' + sender.email_bounces_domain
      final_mail['Return-Receipt-To'] = email_message_id + '@' + sender.email_bounces_domain
    end

    # Mail is buggy and writes message-id set explicitly lowcase
    final_mail = ::Mail.new(final_mail)

    if sender.can_smime_sign?
      final_mail = smime_sign(mail: final_mail)
    end

    self.abstract = final_mail.subject || final_mail.body.to_s[0..64]
    final_message = final_mail.encoded

    dkim_keypair = sender.email_dkim_key_pair
    if dkim_keypair
      location = dkim_keypair.locations.find { |x| x.store.symbol == 'YGGDRA' }
      raise "No keypair found in YGGDRA keystore" if !location

      keystore = location.store
      local_keypair = keystore.pair(location.identifier)

      final_message = Dkim.sign(final_message,
        domain: sender.email_domain,
        selector: sender.email_dkim_selector,
        private_key: local_keypair.private_key,
      )
    end

    self.message = final_message
    self.status = 'PENDING'
  end

  def smime_sign(mail: ::Mail.new(message))

    chain = sender.email_signing_chain
    sign_prv_key = sender.email_signing_key

    sign_address = ::Mail::Address.new(sender.email_address).address

    certs_with_email = chain.select { |x| x.subject.to_a.find { |y| y[0] == 'emailAddress' } }

    raise "Missing certificate with email attribute in chain" if certs_with_email.empty?
    raise "More than one certificate with email attribute in chain" if certs_with_email.count > 1

    sign_cert = certs_with_email.first
    additional_certs = (chain - [sign_cert]).reject { |x| x.subject == x.issuer }

    p7 = OpenSSL::PKCS7.sign(sign_cert, sign_prv_key, mail.encoded, additional_certs, OpenSSL::PKCS7::DETACHED)
    smime0 = OpenSSL::PKCS7::write_smime(p7)

    smail = ::Mail.new(mail.header.to_s + smime0)

    smail
  end

  def send!
    transaction do
      finalize! if status == 'NEW'

      sending_attempted!

      if !Rails.application.config.ml.email_disable
        pars = (sender.email_smtp_pars || Rails.application.config.ml.email_smtp_pars).symbolize_keys
        pars.merge!(
          debug: Rails.application.config.ml.email_debug,
          idle_timeout: 10.seconds,
        )

        client = nil

        begin
          client = AM::SMTP::Client.new(**pars)
        rescue AM::ActorRegistry::ActorExists => e
          client = e.existing_actor
        end

        smtp_sender = ::Mail::Address.new(sender.email_address).address
        smtp_recipients = [ { to: recipient.addr, ext: [ 'NOTIFY=SUCCESS,FAILURE,DELAY' ] } ]

        if Rails.application.config.ml.email_also_bcc && !Rails.application.config.ml.email_also_bcc.empty?
          if Rails.application.config.ml.email_also_bcc.is_a?(Array)
            smtp_recipients += { to: Rails.application.config.ml.email_also_bcc, ext: [] }
          else
            smtp_recipients << { to: Rails.application.config.ml.email_also_bcc, ext: [] }
          end
        end

        if Rails.application.config.ml.email_redirect_to
          smtp_recipients = [ { to: Rails.application.config.ml.email_redirect_to, ext: [] } ]
        end

        begin
          res = client.ask(AM::SMTP::Client::MsgDeliver.new(
            from: email_message_id + '@' + sender.email_bounces_domain,
            from_ext: [ 'RET=HDRS', "ENVID=#{email_message_id}" ],
            rcpts: smtp_recipients,
            body: message,
          )).value
        rescue AM::SMTP::Client::MsgDeliverFailure => e
          sending_failed!(reason: e.title)
          save!
          return
        end

        self.email_data_response = res.data_response
      end

      sent!
      save!
    end
  end

  def self.notify(
        sender: Rails.application.config.ml.default_sender,
        destinations:,
        template:,
        template_context: {},
        objects: [],
        msg_attrs: {},
        exclude_addrs: [],
        flush: true,
        **args)

    sender = Ygg::Ml::Sender.find_by!(symbol: sender) unless sender.is_a?(Ygg::Ml::Sender)

    destinations = [ destinations ] if !destinations.kind_of?(Array)
    objects = [ objects ] if !objects.kind_of?(Array)

    destinations = destinations.map { |dest|
      case dest
      when Ygg::Core::Person
        dest
      when Ygg::Core::Group
        dest.people
      when String
        group = Ygg::Core::Group.find_by_symbol(dest)
        raise ArgumentError, "Group #{dest} not found" if !group
        group.people
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

        person.emails.to_a.reject { |x| exclude_addrs.include?(x.email) }.each do |email|

          msg = notify_raw(
            sender: sender,
            rcpt_name: person.name,
            rcpt: email.email,
            tpl: tpl,
            template_context: template_context,
            person: person,
            objects: objects,
            msg_attrs: msg_attrs,
            flush: false,
          )

          msgs << msg
        end
      end
    end

    queue_flush! if flush

    msgs
  end

  def self.notify_raw(
        sender: Rails.application.config.ml.default_sender,
        rcpt_name: '',
        rcpt:,
        tpl:,
        template_context: {},
        person: nil,
        objects: [],
        msg_attrs: {},
        flush: true,
        **args)

    sender = Ygg::Ml::Sender.find_by_symbol!(sender) unless sender.is_a?(Ygg::Ml::Sender)

    objects = [ objects ] if !objects.kind_of?(Array)

    rcpt_addr = Ygg::Ml::Address.find_or_create_by(addr: rcpt) do |newaddr|
      newaddr.name = rcpt_name
      newaddr.addr_type = 'EMAIL'
    end

    tpl_result = tpl.process(template_context.merge({
      recipient_addr: rcpt_addr.addr,
      recipient_name: rcpt_addr.name,
    }))

    headers = {
      'Auto-Submitted': 'auto-generated',
      'X-Mailer': 'Yggdra Notifier',
      'Content-Type': tpl.content_type,
    }.merge(tpl_result[:email_headers])

    headers['Content-Language'] = tpl.language.iso_639_1 if tpl.language

    mail = ::Mail.new(
      body: tpl_result[:body],
      charset: 'UTF-8',
      from: sender.email_address,
      to: "#{rcpt_addr.name} <#{rcpt_addr.addr}>",
      subject: tpl_result[:subject],
      headers: headers,
    )

    mail['Organization'] ||= sender.email_organization if sender.email_organization
    mail['Reply-To'] ||= sender.email_reply_to if sender.email_reply_to

    msg = Ygg::Ml::Msg::Email.new({
      sender: sender,
      recipient: rcpt_addr,
      person: person,
      msg_objects: objects.map { |x| Ygg::Ml::Msg::Object.new(object: x) },
      status: 'NEW',
      message: mail.encoded,
      abstract: mail.subject || mail.body.to_s[0..64],
    }.merge(msg_attrs))

    msg.save!

    queue_flush! if flush

    msg
  end

  def bounce_received(bounce)
    logger.info "Received bounce for message id=#{email_message_id} for original_recipient=#{bounce.original_recipient}"

    if bounce.original_recipient != recipient.addr
      logger.info "Ignoring bounce for address '#{bounce.original_recipient}' not included in original recipients (#{recipient.addr})"
      return
    end

    case bounce.type
    when 'delivery-status'
      case bounce.action
      when 'delayed'
        case status
        when 'SENT'
          self.status = 'DELAYED'
          save!
        end

      when 'failed'
        self.status = 'BOUNCED'
        recipient.failed_deliveries += 1
        recipient.save!
        save!

        begin
          Ygg::Ml::Msg::Email.notify(destinations: 'ADMINS', template: 'MSG_BOUNCED', template_context: {
            rcpt: recipient.addr,
            diagnostic_code: bounce.diagnostic_code,
          }, exclude_addrs: [ recipient.addr ])
        rescue Ygg::Ml::Msg::TemplateNotFound
        end

      when 'delivered'
        case status
        when 'SENT', 'DELAYED'
          delivered!(time: Time.now) # FIXME
          save!
        end
      end

    when 'disposition-notification'
      if bounce.disposition
        match = /^(?<actionmode>.*)\/(?<sendingmode>.*); +(?<dispositiontype>.*)/.match(bounce.disposition)

        if match[:dispositiontype].downcase == 'displayed'
          self.status = 'DISPLAYED'
          save!
        elsif match[:dispositiontype].downcase == 'deleted'
          self.status = 'DELETED'
          save!
        end
      end
    end
  end

  def check_status!
    if delivery_started_at && delivery_started_at < Time.now - 1.week
      assume_delivered!
    end
  end
end

end
end

