
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

  extend Ygg::Acao::Onda::LastUpdateTracker

  def socio
    Ygg::Acao::MainDb::Socio.find_by(codice_socio: anagrafica.IdAnagrafica)
  end

  class DryRun < StandardError ; end

  def self.trigger_replacement(from: nil, dry_run: false, debug: 0)
    transaction do
      sync_status = Ygg::Acao::SyncStatus.find_or_create_by(symbol: 'DOC_TESTA')
      from ||= sync_status.synced_at - 24.hours

      docs = self.where('DataDocumento >= ?', from)
      docs.each do |doc|
        begin
          doc.trigger_replacement(dry_run: dry_run, debug: debug)
        rescue DryRun
        end
      end

      raise DryRun if dry_run

      sync_status.synced_at = Time.now
      sync_status.save!
    end
  end

  def trigger_replacement(dry_run: false, debug: 0)
    transaction do
      changed = false

      puts "-----------------------------------------------------------------------------------" if debug >= 1

      year = Ygg::Acao::Year.renewal_year.year

      puts "DOCUMENTO NUMERO=#{self.NumeroDocumento} TIPO=#{self.TipoDocumento} #{self.DataDocumento}" if debug >= 1

      anagrafica = Ygg::Acao::Onda::Anagrafica.find(self.IdAnagrafica)
      anagrafica_cliente = Ygg::Acao::Onda::AnagraficaCliente.find(self.IdAnagrafica)
      mdb_socio = Ygg::Acao::MainDb::Socio.find_by(codice_socio_dati_generale: anagrafica_cliente.RifInterno)

      if !mdb_socio
        puts "Socio #{anagrafica_cliente.RifInterno} non trovato" if debug >= 1
        return false
      end

      puts "SOCIO = #{mdb_socio.Nome} #{mdb_socio.Cognome} #{mdb_socio.codice_socio_dati_generale}"

      righe.each do |riga|
        next if !riga.CodArt || riga.CodArt.empty?

        tipo_servizio = Ygg::Acao::MainDb::TipoServizio.find_by(codice_servizio: riga.CodArt)

        puts "Riga #{riga.CodArt} #{tipo_servizio && tipo_servizio.descrizione_servizio}"

        case riga.CodArt
        when '0001S', # Associazione annuale
             '0003S' # Associazione Trainatori Istruttori

          iscr = mdb_socio.iscrizioni.find_by(anno_iscrizione: year)
          if iscr
            puts "  Iscrizione trovata" if debug >= 1
            if iscr.note.include?(self.NumeroDocumento)
              puts "  Iscrizione aggiunto NumeroDocumento #{self.NumeroDocumento}" if debug >= 1

              iscr.note += " #{self.NumeroDocumento}"
              iscr.save!
            end
          end

        when '0002S' # CAV
        when '0005S' # CAV ridotto
        when '0009S'
        when '0014S'
        when '00G1S' # Associazione 2025 <23 anni
        when '0015S' # Noleggio biposto
        when '0017S' # CAA
        when '0018S' # CAP
        when '0031S' # Posto carrello
        when '0065S' # Tessera Fai
        when '84S' # Assicurazione tessera FAI
        when '0022S' # Posto Hangar Motoaliante
        when '0022S' # Posto Hangar
        when '0020S' # Posto Hangar 20-25 m
        when '0023S' # Posto Hangar 15-18 m
        when '0077S' # Posto Hangar DuoDiscus
        when '0075S' # Posto Hangar Motore
        when '0025S' # Posto Hangar Standard
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
          mdb_servizio.data_pagamento = self.DataDocumento
          mdb_servizio.numero_ricevuta = self.NumeroDocumento
          mdb_servizio.dati_aggiuntivi = ''
          mdb_servizio.importo_pagato = self.TotDocumento

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
