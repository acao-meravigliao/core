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

class BarTransaction::VosController < Ygg::Hel::VosBaseController

  def pay_with_satispay(body:, **)
    ensure_authenticated!

    sp_payment = nil

    ActiveRecord::Base.connection_pool.with_connection do
      hel_transaction('Recharge request with satispay') do

        identifier = nil

        loop do
          identifier = 'B' + Password.random(length: 4, symbols: 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789')
          break if !Ygg::Acao::Payment.find_by(identifier: identifier)
        end

        member = session.auth_person.acao_member

        payment = Ygg::Acao::Payment.create!(
          member: member,
          amount: body[:amount],
          payment_method: 'SATISPAY',
          identifier: identifier,
          obj_type: 'Ygg::Acao::BarTransaction', # Class method with be called back on successuful payment
        )

        sp_payment = payment.sp_initiate!(
          description: "Pagamento BAR #{identifier}",
          redirect_url: Rails.application.config.acao.bar_satispay_redirect_url + "/#{payment.id}",
        )
      end
    end

    return {
      success: true,
      redirect_url: sp_payment[:redirect_url],
    }
  end
end

end
end
