
module Ygg
module Acao
module Onda

class Anagrafica < ActiveRecord::Base
  establish_connection :acao_onda

  self.table_name = :anagrafica


end

end
end
end
