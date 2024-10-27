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

class LogBar2 < ActiveRecord::Base
  establish_connection :acao_sql_server

  self.table_name = :log_bar_2

  extend Ygg::Acao::MainDb::LastUpdateTracker
end

end
end
end
