module Ygg
module Acao
module Onda

class Anagrafica < ActiveRecord::Base
  establish_connection :acao_onda

  self.table_name = 'STDAnagrafiche'
  self.primary_key = 'IdAnagrafica'

  has_many :doc_teste,
           class_name: '::Ygg::Acao::Onda::DocTesta',
           foreign_key: 'IdAnagrafica'
end

end
end
end
