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

class OndaDocRiga < ActiveRecord::Base
  establish_connection :acao_onda

  self.table_name = 'ATTDocRighe'
  self.primary_key = 'IdRiga'
end

end
end
end
