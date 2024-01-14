
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
