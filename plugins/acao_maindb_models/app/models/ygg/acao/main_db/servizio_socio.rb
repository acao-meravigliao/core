# frozen_string_literal: true
#
# Copyright (C) 2014-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao
module MainDb

class ServizioSocio < ActiveRecord::Base
  establish_connection :acao_sql_server

  self.table_name = :servizi_socio

  belongs_to :socio,
             :class_name => '::Ygg::Acao::MainDb::Socio',
             :primary_key => 'codice_socio_dati_generale',
             :foreign_key => 'codice_iscritto'

  belongs_to :tipo_servizio,
             :class_name => '::Ygg::Acao::MainDb::TipoServizio',
             :primary_key => 'codice_servizio',
             :foreign_key => 'codice_servizio'

  extend Ygg::Acao::MainDb::LastUpdateTracker
end

end
end
end
