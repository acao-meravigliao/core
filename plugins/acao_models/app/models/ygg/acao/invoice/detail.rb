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
class Invoice < Ygg::PublicModel

class Detail < Ygg::BasicModel
  self.table_name = 'acao.invoice_details'

  belongs_to :invoice,
             class_name: '::Ygg::Acao::Invoice'

  belongs_to :service_type,
             class_name: '::Ygg::Acao::ServiceType',
             optional: true

  has_one :membership,
          class_name: '::Ygg::Acao::Membership',
          foreign_key: 'invoice_detail_id'

  has_one :member_service,
          class_name: '::Ygg::Acao::MemberService',
          foreign_key: 'invoice_detail_id',
          dependent: :destroy

  has_meta_class

  include Ygg::Core::Loggable
  define_default_log_controller(self)
end

end
end
end
