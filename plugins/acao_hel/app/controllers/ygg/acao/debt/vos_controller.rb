#
# Copyright (C) 2016-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

Ygg::Acao::RosterEntry

module Ygg
module Acao

class Debt::VosController < Ygg::Hel::VosBaseController

  class AlreadyPaid < Ygg::Exception ; end

  def create_payment(obj:, body:, **)
    ensure_authenticated!
    raise AuthorizationError unless session.has_global_roles?(:superuser)

    ActiveRecord::Base.connection_pool.with_connection do
      hel_transaction('Payment received') do
        obj.onda_export = body.has_key?(:onda_export) ? body[:onda_export] : true
        obj.onda_export_no_reg = body.has_key?(:onda_export_no_reg) ? body[:onda_export_no_reg] : false
        obj.save!

        if obj.total_due <= 0
          raise AlreadyPaid
        end

        payment = obj.payments.create!(
          member: obj.member,
          amount: body[:amount],
          payment_method: body[:method],
        )

        payment.completed!(
          wire_value_date: nil,
          receipt_code: nil,
        )
      end
    end
#
#    ds.tell(::AM::GrafoStore::Store::MsgObjectCreate.new(
#      obj: new_obj,
#      rels: [
#        { from_as: :roster_entry, to_as: :member, to: new_obj.member_id },
#        { from_as: :entry, to_as: :day, to: new_obj.roster_day_id },
#      ]
#    ))
  end

  def onda_retry(obj:, **)
    ensure_authenticated!
    raise AuthorizationError unless session.has_global_roles?(:superuser)

    obj.export_to_onda!
  end

  def pay_with_satispay(obj:, **)
    ensure_authenticated!

    sp_payment = nil

    hel_transaction('Payment') do
      if obj.total_due <= 0
        raise AlreadyPaid
      end

      member = session.auth_person.acao_member

      payment = Ygg::Acao::Payment.create!(
        member: member,
        debt: obj,
        obj: obj,
        amount: obj.total_due,
        payment_method: 'SATISPAY',
      )

      sp_payment = payment.sp_initiate!(
        description: "Pagamento #{debt.identifier}",
        redirect_url: Rails.application.config.acao.satispay_redirect_url + "/#{payment.id}",
      )
    end

    return {
      success: true,
      redirect_url: sp_payment[:redirect_url],
    }
  end

end

end
end
