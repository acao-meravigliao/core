# frozen_string_literal: true
#
# Copyright (C) 2017-2025, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao
class Debt < Ygg::PublicModel

class Detail < Ygg::BasicModel
  self.table_name = 'acao.debt_details'

  belongs_to :service_type,
             class_name: 'Ygg::Acao::ServiceType',
             optional: true

  belongs_to :obj,
             polymorphic: true,
             optional: true

  gs_rel_map << { from: :detail, to: :debt, to_cls: '::Ygg::Acao::Debt', from_key: 'debt_id' }

  has_meta_class

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  def total
    amount + (amount * vat)
  end
end

end
end
end
