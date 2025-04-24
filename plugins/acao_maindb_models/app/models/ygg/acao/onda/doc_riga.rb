
module Ygg
module Acao
module Onda

class DocRiga < ActiveRecord::Base
  establish_connection :acao_onda

  self.table_name = 'ATTDocRighe'
  self.primary_key = 'IdRiga'

  belongs_to :doc_testa,
           class_name: '::Ygg::Acao::Onda::DocTesta',
           foreign_key: 'IdDoc'
end

end
end
end
