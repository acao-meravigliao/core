
module Ygg
module Acao
module MainDb

class Volo < ActiveRecord::Base
  establish_connection :acao_sql_server

  self.table_name = :voli

  extend Ygg::Acao::MainDb::LastUpdateTracker

  # id_voli: 87027,
  # data_volo: Thu, 20 Jul 2023 00:00:00.000000000 UTC +00:00,
  # codice_pilota_aereo: 0,
  # codice_secondo_pilota_aereo: 0,
  # codice_pilota_aliante: 968,
  # codice_secondo_pilota_aliante: 0,
  # marche_aereo: "NO      ",
  # marche_aliante: "I-ILMA  ",
  # tipo_volo_club: 6,
  # tipo_aereo_aliante: 4,
  # ora_decollo_aereo: Thu, 20 Jul 2023 09:36:00.000000000 UTC +00:00,
  # ore_atterraggio_aereo: Thu, 20 Jul 2023 09:36:00.000000000 UTC +00:00,
  # ora_atterraggio_aliante: Thu, 20 Jul 2023 10:09:00.000000000 UTC +00:00,
  # durata_volo_aereo_minuti: 0,
  # durata_volo_aliante_minuti: 33,
  # quota: 0,
  # bollini_volo: 0.0,
  # check_chiuso: false,
  # dep: "LILE      ",
  # arr: "LILC      ",
  # num_att: nil,
  # data_att: nil,
  # lastmod: Thu, 20 Jul 2023 08:20:09.963079800 UTC +00:00>


end

end
end
end
