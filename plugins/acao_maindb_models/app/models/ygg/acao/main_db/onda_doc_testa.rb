
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
