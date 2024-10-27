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

class OndaDocTesta < ActiveRecord::Base
  establish_connection :acao_onda

  self.table_name = 'ATTDocTeste'
  self.primary_key = 'IdDoc'
end

end
end
end
