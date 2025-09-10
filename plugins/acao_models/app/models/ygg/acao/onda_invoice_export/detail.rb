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
class OndaInvoiceExport < Ygg::PublicModel

class Detail < Ygg::BasicModel
  self.table_name = 'acao.onda_invoice_export_details'

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
