# frozen_string_literal: true
#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Payment < Ygg::PublicModel
  self.table_name = 'acao.payments'

  belongs_to :member,
             class_name: 'Ygg::Acao::Member'

  belongs_to :debt,
             class_name: 'Ygg::Acao::Debt',
             optional: true

  belongs_to :obj,
             polymorphic: true,
             optional: true

  belongs_to :sp_sender,
             class_name: '::Ygg::Acao::SatispayEntity',
             optional: true

  belongs_to :sp_receiver,
             class_name: '::Ygg::Acao::SatispayEntity',
             optional: true

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  include Ygg::Core::Notifiable

  gs_rel_map << { from: :payment, to: :member, to_cls: '::Ygg::Acao::Member', from_key: 'member_id' }
  gs_rel_map << { from: :payment, to: :debt, to_cls: '::Ygg::Acao::Debt', from_key: 'debt_id' }
# TODO: implement polymorphic
#  gs_rel_map << { from: :payment, to: :obj, from_key: 'debt_id' }
  gs_rel_map << { from: :payment, to: :sp_sender, to_cls: '::Ygg::Acao::SatispayEntity', from_key: 'sp_sender_id' }
  gs_rel_map << { from: :payment, to: :sp_receiver, to_cls: '::Ygg::Acao::SatispayEntity', from_key: 'sp_receiver_id' }

  after_initialize do
    if new_record? && !identifier
      identifier = nil

      loop do
        identifier = 'P' + Password.random(length: 4, symbols: 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789')
        break if !self.class.find_by_identifier(identifier)
      end

      self.identifier = identifier
    end
  end

  idxc_cached
  self.idxc_sensitive_attributes = [
    :person_id,
  ]

  class NotDeletable < StandardError ; end
  before_destroy do
    if state != 'PENDING'
      raise NotDeletable
    end
  end

  def completed!(wire_value_date: nil, receipt_code: nil)
    transaction do
      raise "Payment in state #{state} cannot be confirmed" if state != 'PENDING'

      self.state = 'COMPLETED'
      self.completed_at = Time.now
      self.wire_value_date = wire_value_date
      self.receipt_code = receipt_code
      save!

      if debt
        debt.one_payment_has_been_completed!(payment: self)
      elsif obj
        obj.one_payment_has_been_completed!(payment: self)
      elsif obj_type
        Object.const_get(obj_type, false).one_payment_has_been_completed!(payment: self)
      end

      if member
        Ygg::Ml::Msg.notify(destinations: member.person, template: 'PAYMENT_COMPLETED', template_context: {
          first_name: member.person.first_name,
          code: identifier,
        }, objects: self)
      end
    end
  end

  def cancel!
    transaction do
      lock!

      raise "Payment in state #{state} cannot be canceled" if state != 'PENDING'

      self.state = 'CANCELED'
      save!

      #Ygg::Ml::Msg.notify(destinations: debt.member.person, template: 'PAYMENT_COMPLETED', template_context: {
      #  first_name: debt.member.person.first_name,
      #  code: identifier,
      #}, objects: self)
    end
  end

  require 'am/satispay/client'

  def sp_client
    @sp_client ||= AM::Satispay::Client.new(
      endpoint: Rails.application.config.acao.satispay_endpoint,
      rsa_key: Rails.application.credentials.satispay_rsa_key,
      key_id: Rails.application.credentials.satispay_key_id
    )
  end

  def sp_initiate!(redirect_url: nil, description:)

    self.sp_idempotency_key = SecureRandom.uuid

    metadata = {
      payment_id: id,
      member_id: member && member.id,
      obj_id: obj && obj.id,
    }

    if debt
      description ||= debt.identifier
      redirect_url ||= "https://servizi.acao.it/authen/debt/show/#{id}"
      metadata[:debt_id] = debt.id
    else
      raise "Missing redirect_url" if !redirect_url
      raise "Missing description" if !description
    end

    sp_payment = sp_client.payment_create(
      flow: 'MATCH_CODE',
      amount_unit: (amount * 100).to_i,
      currency: 'EUR',
      external_code: description,
      callback_url: Rails.application.config.acao.satispay_callback_url,
      redirect_url: redirect_url,
      metadata: metadata,
      idempotency_key: self.sp_idempotency_key,
    )

puts "SP_PAYMENT=#{sp_payment}"

    self.sp_id = sp_payment[:id]
    self.sp_code = sp_payment[:code_identifier]
    self.sp_type = sp_payment[:type]
    self.sp_status = sp_payment[:status]
    self.sp_status_ownership = sp_payment[:status_ownership]
    self.sp_expired = sp_payment[:expired]

    sp_update_sender(sp_payment)
    sp_update_receiver(sp_payment)

    self.sp_daily_closure_id = sp_payment[:daily_closure] && sp_payment[:daily_closure][:id]
    self.sp_daily_closure_date = sp_payment[:daily_closure] && sp_payment[:daily_closure][:date]
    self.sp_insert_date = sp_payment[:insert_date]
    self.sp_expire_date = sp_payment[:expire_date]
    self.sp_description = sp_payment[:description]
    self.sp_flow = sp_payment[:flow]
    self.sp_external_code = sp_payment[:external_code]

    save!

    sp_payment
  end

  def sp_update!(force: false)
    if sp_status != 'PENDING' && !force
      return 'Nothing to do'
    end

    lock!

    sp_payment = sp_client.payment_get(sp_id)

puts "SP_UPDATE SP_PAYMENT=#{sp_payment}"

    transaction do
      orig_sp_status = sp_status

      self.sp_status = sp_payment[:status]
      self.sp_status_ownership = sp_payment[:status_ownership]
      self.sp_expired = sp_payment[:expired]

      sp_update_sender(sp_payment)
      sp_update_receiver(sp_payment)

      self.sp_daily_closure_id ||= sp_payment[:daily_closure] && sp_payment[:daily_closure][:id]
      self.sp_daily_closure_date ||= sp_payment[:daily_closure] && sp_payment[:daily_closure][:date]
      self.sp_insert_date ||= sp_payment[:insert_date]
      self.sp_expire_date ||= sp_payment[:expire_date]
      self.sp_description = sp_payment[:description]
      self.sp_flow ||= sp_payment[:flow]
      self.sp_external_code = sp_payment[:external_code]

      if orig_sp_status == 'PENDING'
        case sp_status
        when 'ACCEPTED'
          completed!
        when 'CANCELED'
          cancel!
        end
      end

      save!
    end

    sp_payment
  end

  def sp_update_sender(sp_payment)
    if sp_payment[:sender] && sp_payment[:sender][:id]
      self.sp_sender ||= Ygg::Acao::SatispayEntity.find_or_create_by!(id: sp_payment[:sender][:id]) do |s|
        s.type = sp_payment[:sender][:type]
        s.name = sp_payment[:sender][:name]
      end

      if sp_payment[:sender][:profile_pictures]
        sp_sync_profile_pictures(sp_sender, sp_payment[:sender][:profile_pictures])
      end
    end
  end

  def sp_update_receiver(sp_payment)
    if sp_payment[:receiver] && sp_payment[:receiver][:id]
      self.sp_receiver ||= Ygg::Acao::SatispayEntity.find_or_create_by!(id: sp_payment[:receiver][:id]) do |s|
        s.type = sp_payment[:receiver][:type]
        s.name = sp_payment[:receiver][:name]
      end
    end
  end

  def sp_sync_profile_pictures(entity, pictures)
    if pictures[:data]
      pictures[:data].each do |pp|
        entity.profile_pictures.find_or_create_by!(id: pp[:id]) do |ppm|
          ppm.source = 'SATISPAY'
          ppm.url = pp[:url]
          ppm.width = pp[:width]
          ppm.height = pp[:height]
          ppm.is_original = pp[:is_original]
        end
      end
    end
  end

  def self.run_chores!
    transaction do
      where(payment_method: 'SATISPAY', sp_status: 'PENDING').each do |payment|
        transaction do
          payment.lock!
          payment.sp_update!
        end
      end
    end
  end
end

end
end
