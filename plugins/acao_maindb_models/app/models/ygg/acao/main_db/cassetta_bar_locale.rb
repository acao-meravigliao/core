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

class CassettaBarLocale < ActiveRecord::Base
  establish_connection :acao_sql_server

  self.table_name = :cassetta_bar_locale

  extend Ygg::Acao::MainDb::LastUpdateTracker
end

end
end
end
