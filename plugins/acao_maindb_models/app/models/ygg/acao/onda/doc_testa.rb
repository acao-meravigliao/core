
module Ygg
module Acao
module Onda

class DocTesta < ActiveRecord::Base
  establish_connection :acao_onda

  self.table_name = 'ATTDocTeste'
  self.primary_key = 'IdDoc'

  has_many :righe,
           class_name: '::Ygg::Acao::Onda::DocRiga',
           foreign_key: 'IdDoc'

  belongs_to :anagrafica,
           class_name: '::Ygg::Acao::Onda::Anagrafica',
           foreign_key: 'IdAnagrafica'

  belongs_to :anagrafica_cliente,
           class_name: '::Ygg::Acao::Onda::AnagraficaCliente',
           foreign_key: 'IdAnagrafica'

  def self.fix_servizi(from: Time.new(2024,1,1))
    soci_modificati = []

    Ygg::Acao::Onda::DocTesta.where('DataDocumento > ?', from).each do |x|
      res = x.fix_servizi
      if res
        soci_modificati << res
      end
    end

    soci_modificati
  end

  def fix_servizi
    changed = false

    puts "-----------------------------------------------------------------------------------"

    anagrafica = Ygg::Acao::Onda::Anagrafica.find(self.IdAnagrafica)
    anagrafica_cliente = Ygg::Acao::Onda::AnagraficaCliente.find(self.IdAnagrafica)
    mdb_socio = Ygg::Acao::MainDb::Socio.find_by(codice_socio_dati_generale: anagrafica_cliente.RifInterno)

    if !mdb_socio
      puts "Socio #{anagrafica_cliente.RifInterno} non trovato"
      return false
    end

    puts "FATTURA = #{self.NumeroDocumento} #{self.DataDocumento}"
    puts "SOCIO = #{mdb_socio.Nome} #{mdb_socio.Cognome} #{mdb_socio.codice_socio_dati_generale}"

    righe.each do |riga|
      tipo_servizio = Ygg::Acao::MainDb::TipoServizio.find_by(codice_servizio: riga.CodArt)

      puts "SERVIZIO #{riga.CodArt} #{tipo_servizio && tipo_servizio.descrizione_servizio}"

      next if ![ '0005S', '0014S', '0009S', '0002S', '0015S', ].include?(riga.CodArt)

      if tipo_servizio
        mdb_servizio = mdb_socio.servizi.find_by(codice_servizio: riga.CodArt, anno: 2024)
        if !mdb_servizio
          puts "SERVIZIO #{riga.CodArt} CREATO"
          mdb_servizio = mdb_socio.servizi.build(codice_servizio: riga.CodArt, anno: 2024)
        else
          puts "SERVIZIO #{riga.CodArt} TROVATO ID=#{mdb_servizio.id_servizi_socio} PAGATO=#{mdb_servizio.pagato}"
        end

        if !mdb_servizio.pagato
          mdb_servizio.pagato = true
          mdb_servizio.data_pagamento = Time.now
          mdb_servizio.numero_ricevuta = self.NumeroDocumento

          puts "SERVIZIO MODIFICATO #{mdb_servizio.changes}"

          mdb_servizio.save!

          changed = true
        end
      end
    end

    changed && mdb_socio.codice_socio_dati_generale
  end
end

end
end
end
