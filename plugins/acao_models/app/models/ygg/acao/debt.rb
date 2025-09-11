# frozen_string_literal: true
#
# Copyright (C) 2017-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Debt < Ygg::PublicModel
  self.table_name = 'acao.debts'

  has_meta_class

  belongs_to :member,
             class_name: 'Ygg::Acao::Member'

  has_many :details,
           class_name: 'Ygg::Acao::Debt::Detail',
           embedded: true,
           dependent: :destroy,
           autosave: true

  has_many :payments,
           class_name: 'Ygg::Acao::Payment'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  include Ygg::Core::Notifiable

  def self.readables_relation(person_id:)
    joins(:readables).where(core_readables_uuid: { person_id: person_id })
  end
  ########################################### ^^^^^^^^^

  after_initialize do
    if new_record?
      assign_identifier!
    end
  end

  idxc_cached
  self.idxc_sensitive_attributes = [
    :person_id,
  ]

  def assign_identifier!
    identifier = nil

    loop do
      identifier = "D" + Password.random(length: 4, symbols: 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789')
      break if !self.class.find_by_identifier(identifier)
    end

    self.identifier = identifier
  end

  def total
    details.reduce(0) { |a,x| a + x.price }
  end

  def one_payment_has_been_completed!(payment)
    if payments.all? { |x| x.state == 'COMPLETED' }
      paid_in_full!
    else
      self.payment_state = 'PARTIALLY_PAID'
      save!
    end
  end

  def paid_in_full!
    raise "No payment registered" if payments.empty?

    self.payment_state = 'PAID_IN_FULL'
    self.completed_at = Time.now
    save!

    details.all.each do |detail|
      if detail.obj && detail.obj.respond_to?(:payment_completed!)
        detail.obj.payment_completed!
      end

      # TODO: use detail.obj?
      if detail.service_type.symbol == 'SKYSIGHT'
        Ygg::Acao::SkysightCode.assign_and_send!(person: person)
      end
    end

    create_pending_payment!
    if onda_export_status == nil
      self.onda_export_status = 'PENDING'
      save!

      export_to_onda!
    end
  end

  def export_to_onda!
    raise "No payment registered" if payments.empty?

    onda_export = nil

    transaction do
      onda_export = Ygg::Acao::OndaInvoiceExport.create!(
        member: member,
        identifier: "#{Time.now.strftime('%Y%m%d_%H%M%S')}_#{identifier}",
        descr: descr,
        notes: notes,
        payment_method: payments.first.payment_method,
      )

      details.each do |detail|
        if detail.service_type.onda_1_type && detail.service_type.onda_1_code
          onda_export.details.create(
            count: detail.count * detail.service_type.onda_1_cnt,
            code: detail.service_type.onda_1_code,
            item_type: detail.service_type.onda_1_type,
            descr: detail.descr,
            amount: detail.amount,
            vat: detail.vat,
          )
        end

        if detail.service_type.onda_2_type && detail.service_type.onda_2_code
          onda_export.details.create(
            count: detail.count * detail.service_type.onda_1_cnt,
            code: detail.service_type.onda_2_code,
            item_type: detail.service_type.onda_2_type,
            descr: detail.descr,
            amount: detail.amount,
            vat: detail.vat,
          )
        end
      end
    end

    onda_export.write_file!
  end

  def generate_payment!(reason: "Pagamento fattura", timeout: 10.days)
    Ygg::Acao::Payment.create(
      person: person,
      invoice: self,
      created_at: Time.now,
      expires_at: Time.now + timeout,
      payment_method: payment_method,
      reason_for_payment: reason,
      amount: total,
    )
  end

  def self.run_chores!
    all.each do |debtt|
      debt.run_chores!
    end
  end

  def run_chores!
    transaction do
      now = Time.now
      last_run = last_chore || Time.new(0)

      run_expiration_chores(now: now, last_run: last_run)

      self.last_chore = now

      save!
    end
  end

  def run_expiration_chores(now:, last_run:)
    when_in_advance = 5.days - 10.hours

    if expires_at && state == 'PENDING'
      if (expires_at.beginning_of_day - when_in_advance).between?(last_run, now) && !expires_at.between?(last_run, now)
        Ygg::Ml::Msg.notify(destinations: member.person, template: 'PAYMENT_NEAR_EXPIRATION', template_context: {
          first_name: member.person.first_name,
          code: identifier,
          created_at: created_at.strftime('%Y-%m-%d'),
          expires_at: expires_at.strftime('%Y-%m-%d'),
        })
      end

      if expires_at.between?(last_run, now)
        Ygg::Ml::Msg.notify(destinations: member.person, template: 'PAYMENT_EXPIRED', template_context: {
          first_name: member.person.first_name,
          code: identifier,
          created_at: created_at.strftime('%Y-%m-%d'),
          expires_at: expires_at.strftime('%Y-%m-%d'),
        })
      end
    end
  end

  PAYMENT_METHOD_MAP = {
    'WIRE'      => 'BB',
    'CHECK'     => 'AS',
    'SATISPAY'  => 'SP',
    'CARD'      => 'CC',
    'CASH'      => 'CO',
  }

end

end
end
