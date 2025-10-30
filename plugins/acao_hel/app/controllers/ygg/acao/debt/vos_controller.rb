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
      ActiveRecord::Base.transaction do
        obj.onda_export = body.has_key?(:onda_export) ? body[:onda_export] : true
        obj.onda_export_no_reg = body.has_key?(:onda_export_no_reg) ? body[:onda_export_no_reg] : false
        obj.save!

        if obj.total_due <= 0
          raise  AlreadyPaid
        end

        hel_transaction('Create payment') do
          payment = obj.payments.create!(
            amount: body[:amount],
            payment_method: body[:method],
          )

          payment.completed!(
            wire_value_date: nil,
            receipt_code: nil,
          )
        end
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
end

end
end
