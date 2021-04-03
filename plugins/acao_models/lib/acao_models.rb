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
#      has_one :acao_pilot,
#               class_name: '::Ygg::Acao::Pilot'

      has_many :acao_memberships,
               class_name: '::Ygg::Acao::Membership'

      has_many :acao_payments,
               class_name: '::Ygg::Acao::Payment'

      has_many :acao_roster_entries,
               class_name: '::Ygg::Acao::RosterEntry'

      has_many :acao_token_transactions,
               class_name: '::Ygg::Acao::TokenTransaction'

      has_many :acao_bar_transactions,
               class_name: '::Ygg::Acao::BarTransaction'
    end
  end
end

end
end
