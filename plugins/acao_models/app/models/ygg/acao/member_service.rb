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

class MemberService < Ygg::PublicModel
  self.table_name = 'acao.member_services'

  belongs_to :member,
             class_name: 'Ygg::Acao::Member'

  belongs_to :invoice_detail,
             class_name: 'Ygg::Acao::Invoice::Detail',
             optional: true

  belongs_to :service_type,
             class_name: 'Ygg::Acao::ServiceType'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  def payment_completed!
  end
end

end
end
