
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

  class DryRun < StandardError ; end

  def self.trigger_replacement(from: nil, dry_run: false)
    transaction do
      sync_status = Ygg::Acao::SyncStatus.find_or_create_by(symbol: 'DOC_TESTA')
      from ||= sync_status.synced_at

      docs = self.where('DataDocumento >= ?', from)
      docs.each do |doc|
        begin
          doc.trigger_replacement(dry_run: dry_run)
        rescue DryRun
        end
      end

      raise DryRun if dry_run

      sync_status.synced_at = Time.now
      sync_status.save!
    end
  end

  def trigger_replacement(dry_run: false)
    transaction do
      changed = false

      puts "-----------------------------------------------------------------------------------"

      year = self.DataDocumento.year

      puts "FATTURA = #{self.NumeroDocumento} #{self.DataDocumento}"

      anagrafica = Ygg::Acao::Onda::Anagrafica.find(self.IdAnagrafica)
      anagrafica_cliente = Ygg::Acao::Onda::AnagraficaCliente.find(self.IdAnagrafica)
      mdb_socio = Ygg::Acao::MainDb::Socio.find_by(codice_socio_dati_generale: anagrafica_cliente.RifInterno)

      if !mdb_socio
        puts "Socio #{anagrafica_cliente.RifInterno} non trovato"
        return false
      end

      puts "SOCIO = #{mdb_socio.Nome} #{mdb_socio.Cognome} #{mdb_socio.codice_socio_dati_generale}"

      righe.each do |riga|
        next if !riga.CodArt || riga.CodArt.empty?

        tipo_servizio = Ygg::Acao::MainDb::TipoServizio.find_by(codice_servizio: riga.CodArt)

        puts "Riga #{riga.CodArt} #{tipo_servizio && tipo_servizio.descrizione_servizio}"

        case riga.CodArt
        #when '0001S' # Associazione annuale
        when '0002S' # CAV
        when '0005S' # CAV ridotto
        when '0009S'
        when '0014S'
        when '0015S' # Noleggio biposto
        else
          puts "  Ignorata"

          next
        end

        mdb_servizio = mdb_socio.servizi.find_by(codice_servizio: riga.CodArt, anno: year)
        if !mdb_servizio
          puts "  Servizio #{riga.CodArt} CREATO"
          mdb_servizio = mdb_socio.servizi.build(codice_servizio: riga.CodArt, anno: year)
        else
          puts "  Servizio #{riga.CodArt} TROVATO ID=#{mdb_servizio.id_servizi_socio} PAGATO=#{mdb_servizio.pagato}"
        end

        if !mdb_servizio.pagato
          mdb_servizio.pagato = true
          mdb_servizio.data_pagamento = Time.now
          mdb_servizio.numero_ricevuta = self.NumeroDocumento

          puts "  Servizio MODIFICATO #{mdb_servizio.changes}"

          mdb_servizio.save!

          changed = true
        end
      end

      raise DryRun if dry_run
    end

    changed
  end

end

end
end
end
