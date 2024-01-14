
module Ygg
module Acao
module MainDb

class TipoServizio < ActiveRecord::Base
  establish_connection :acao_sql_server

  self.table_name = :tipi_servizi

  has_many :servizio,
             :class_name => '::Ygg::Acao::MainDb::ServizioSocio',
             :primary_key => 'codice_servizio',
             :foreign_key => 'codice_servizio'

  extend Ygg::Acao::MainDb::LastUpdateTracker
end

end
end
end
