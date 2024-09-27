#
# Copyright (C) 2008-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'acao_models/version'

module Ygg
module Acao

class ModelsEngine < Rails::Engine
  config.acao = ActiveSupport::OrderedOptions.new if !defined? config.acao
  config.acao.soci_ml_dry_run = true
  config.acao.onda_import_dir = '/opt/onda_export/onda_import'
  config.acao.satispay_http_debug = 3

  config.acao.printer = "printer@xerox.acao.it"

  config.to_prepare do
    Ygg::Core::Person.class_eval do
      has_one :acao_member,
               class_name: '::Ygg::Acao::Member'
    end
  end
end

end
end
