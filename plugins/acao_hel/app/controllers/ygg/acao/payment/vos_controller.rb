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

class Payment::VosController < Ygg::Hel::VosBaseController
  def sp_update(obj:, body:, **)
    ensure_authenticated!

    hel_transaction('Satispay update') do
      obj.sp_update!
    end

#    ds.tell(::AM::GrafoStore::Store::MsgObjectUpdate.new(
#      id: obj.id,
#      vals: obj.attributes,
#    ))

    return {
      sp_status: obj.sp_status,
    }
  end
end

end
end
