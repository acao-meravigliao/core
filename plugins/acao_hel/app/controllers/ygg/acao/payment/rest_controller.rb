#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Payment::RestController < Ygg::Hel::RestController
  ar_controller_for Ygg::Acao::Payment

  load_role_defs!

  def satispay_callback
    payment_id = request.query_parameters[:payment_id]

    begin
      hel_transaction('Satispay state change') do
        payment = Ygg::Acao::Payment.find_by!(sp_id: payment_id).lock(true)
        payment.sp_update!
      end
    rescue AM::Satispay::Client::GenericError
    end

    ar_respond_with({ thanks: true })
  end
end

end
end
