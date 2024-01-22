
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
