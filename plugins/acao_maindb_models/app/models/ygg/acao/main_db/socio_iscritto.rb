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

class SocioIscritto < ActiveRecord::Base
  establish_connection :acao_sql_server

  self.table_name = :soci_iscritti

  belongs_to :socio,
             :class_name => '::Ygg::Acao::MainDb::Socio',
             :primary_key => 'codice_socio_dati_generale',
             :foreign_key => 'codice_iscritto'

  extend Ygg::Acao::MainDb::LastUpdateTracker
end

end
end
end
