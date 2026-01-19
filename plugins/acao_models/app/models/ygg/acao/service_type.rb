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

class ServiceType < Ygg::PublicModel
  self.table_name = 'acao.service_types'

  has_many :member_services,
           class_name: 'Ygg::Acao::MemberService'

  has_meta_class

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  gs_rel_map << { from: :service_type, to: :service, to_cls: '::Ygg::Acao::MemberService', to_key: 'service_type_id', }
  gs_rel_map << { from: :service_type, to: :detail, to_cls: '::Ygg::Acao::Debt', to_key: 'service_type_id' }
end

end
end
