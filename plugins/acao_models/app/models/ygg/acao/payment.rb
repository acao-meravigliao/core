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

  belongs_to :debt,
             class_name: 'Ygg::Acao::Debt'

  has_many :satispay_charges,
           class_name: 'Ygg::Acao::Payment::SatispayCharge',
           embedded: true,
           autosave: true,
           dependent: :destroy

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  include Ygg::Core::Notifiable

  gs_rel_map << { from: :payment, to: :debt, to_cls: '::Ygg::Acao::Debt', from_key: 'debt_id' }

  after_initialize do
    if new_record?
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
      lock!

      raise "Payment in state #{state} cannot be confirmed" if state != 'PENDING'

      self.state = 'COMPLETED'
      self.completed_at = Time.now
      self.wire_value_date = wire_value_date
      self.receipt_code = receipt_code
      save!

      if debt
        debt.one_payment_has_been_completed!(self)
      end

      # Debts are now only for pre-invoice contexts
      #
      #if invoice
      #  invoice.one_payment_has_been_completed!(self)
      #end

      Ygg::Ml::Msg.notify(destinations: person, template: 'PAYMENT_COMPLETED', template_context: {
        first_name: person.first_name,
        code: identifier,
      }, objects: self)
    end
  end

  require 'am/satispay/client'

  def satispay_initiate(phone_number:)
    satispay_charges.each do |c|
      c.sync! if c.status == 'REQUIRED'
      raise "Charge is still pending" if c.status == 'REQUIRED'
    end

    charge = Ygg::Acao::Payment::SatispayCharge.new(
      user_phone_number: phone_number,
      amount: amount,
      description: "Pagamento Online codice #{identifier}",
      idempotency_key: SecureRandom.base64(10),
    )

    satispay_charges << charge

    charge.save!
    charge.initiate!
  end

  def satispay_callback(charge_id:)
    charge = satispay_charges.find_by!(charge_id: charge_id)
    charge.sync!

    case charge.status
    when 'REQUIRED'
    when 'SUCCESS'
      completed!
    when 'FAILURE'
    else
    end
  end
end

end
end
