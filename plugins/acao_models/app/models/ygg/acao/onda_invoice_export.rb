# frozen_string_literal: true
#
# Copyright (C) 2017-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class OndaInvoiceExport < Ygg::PublicModel
  self.table_name = 'acao.onda_invoice_exports'

  has_meta_class

  belongs_to :member,
             class_name: 'Ygg::Acao::Member'

  belongs_to :debt,
             class_name: 'Ygg::Acao::Debt',
             optional: true

  has_many :details,
           class_name: 'Ygg::Acao::OndaInvoiceExport::Detail',
           embedded: true,
           dependent: :destroy,
           autosave: true

  gs_rel_map << { from: :onda_invoice_export, to: :debt, to_cls: '::Ygg::Acao::Debt', from_key: 'debt_id' }
  gs_rel_map << { from: :onda_invoice_export, to: :detail, to_cls: '::Ygg::Acao::OndaInvoiceExport::Detail', to_key: 'onda_invoice_export_id' }

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  include Ygg::Core::Notifiable

  idxc_cached
  self.idxc_sensitive_attributes = [
    :person_id,
  ]

  def total
    details.reduce(0) { |a,x| a + x.total }
  end

  def self.run_chores!
    check_rejects!

#    all.each do |invoice|
#      invoice.run_chores!
#    end
  end

  def run_chores!
    transaction do
      now = Time.now
      last_run = last_chore || Time.new(0)

      self.last_chore = now

      save!
    end
  end

  PAYMENT_METHOD_MAP = {
    'WIRE'      => 'BB',
    'CHECK'     => 'AS',
    'SATISPAY'  => 'SP',
    'CARD'      => 'CC',
    'DEBT'      => 'BA',
    'CASH'      => 'CO',
  }

  def build_xml_for_onda_fattura(no_reg: false)
    cod_pagamento = PAYMENT_METHOD_MAP[payment_method.upcase]

    person = member.person

    ric_fisc = XmlInterface::RicFisc.new do |ric_fisc|
      ric_fisc.cod_schema = 'ACAOFATT'
      ric_fisc.data_ora_creazione = created_at
      ric_fisc.docus[0] = XmlInterface::RicFisc::Docu.new do |docu|
        docu.testa = XmlInterface::RicFisc::Docu::Testa.new do |testa|
          testa.abbuono = 0
          testa.acconto = 0
          testa.acconto_in_cassa = true
          testa.calcoli_su_imponibile = false
          testa.cod_divisa = 'EUR'
          testa.cod_pagamento = cod_pagamento
          testa.commento = no_reg ? 'NO-REG' : ''
          testa.contrassegno = 0
          testa.nostro_rif = identifier
          testa.tot_documento = 0
          testa.tot_imponibile = 0
          testa.tot_imposta = 0
          testa.vostro_rif = identifier
          testa.dati_controparte = XmlInterface::RicFisc::Docu::Testa::DatiControparte.new
          testa.dati_controparte.citta = person.residence_location.city
          testa.dati_controparte.codice_fiscale = person.italian_fiscal_code || person.vat_number
          testa.dati_controparte.e_mail = person.emails.first && person.emails.first.email
          testa.dati_controparte.indirizzo = person.residence_location.full_address
          testa.dati_controparte.partita_iva = person.vat_number || ''
          testa.dati_controparte.ragione_sociale = person.name
          testa.dati_controparte.codice_destinatario = '0000000'
        end

        docu.righe = XmlInterface::RicFisc::Docu::Righe.new do |righe|
          details.each do |det|
            righe.righe << XmlInterface::RicFisc::Docu::Righe::Riga.new do |riga|
              riga.cod_art = det.code
              riga.cod_iva = ''
              riga.cod_un_mis = 'NR.'
              riga.descrizione = det.data ? "#{det.descr} #{det.data}" : ''
              riga.imponibile = ''
              riga.importo_sconto = 0
              riga.imposta = ''
              riga.perc_sconto1 = 0
              riga.perc_sconto2 = 0
              riga.perc_sconto3 = 0
              riga.perc_sconto4 = 0
              riga.qta = det.count
              riga.tipo_riga = det.item_type
              riga.totale = ''
              riga.valore_unitario = ''

              riga.dati_art_serv = XmlInterface::RicFisc::Docu::Righe::Riga::DatiArtServ.new do |dati_art_serv|
                dati_art_serv.cod_art = det.code
                dati_art_serv.cod_un_mis_base = 'NR.'
                dati_art_serv.descrizione = det.data ? "#{det.descr} #{det.data}" : ''
                dati_art_serv.tipo_articolo = det.item_type
              end
            end
          end

          righe.righe << XmlInterface::RicFisc::Docu::Righe::Riga.new do |riga|
            riga.cod_art = ''
            riga.cod_iva = ''
            riga.cod_un_mis = ''
            riga.descrizione = "Acquisto online, codice #{identifier}"
            riga.imponibile = ''
            riga.importo_sconto = 0
            riga.imposta = ''
            riga.perc_sconto1 = 0
            riga.perc_sconto2 = 0
            riga.perc_sconto3 = 0
            riga.perc_sconto4 = 0
            riga.qta = 0
            riga.tipo_riga = 3
            riga.totale = ''
            riga.valore_unitario = ''

            riga.dati_art_serv = XmlInterface::RicFisc::Docu::Righe::Riga::DatiArtServ.new do |dati_art_serv|
              dati_art_serv.cod_art = '00000'
              dati_art_serv.cod_un_mis_base = 'NR.'
              dati_art_serv.descrizione = ''
              dati_art_serv.tipo_articolo = 2
            end
          end
        end

        docu.coda = XmlInterface::RicFisc::Docu::Coda.new do |coda|
          coda.aliquota1 = 0
          coda.aliquota2 = 0
          coda.aliquota3 = 0
          coda.aliquota4 = 0
          coda.aliquota5 = 0
          coda.castelletto_manuale = false
          coda.causale_trasporto = ''
          coda.cod_iva1 = 0
          coda.cod_iva2 = 0
          coda.cod_iva3 = 0
          coda.cod_iva4 = 0
          coda.cod_iva5 = 0
          coda.cod_trasporto = 0
          coda.id_indirizzo_fattura = 0
          coda.id_indirizzo_merce = 0
          coda.id_vettore1 = 0
          coda.imponibile1 = 0
          coda.imponibile2 = 0
          coda.imponibile3 = 0
          coda.imponibile4 = 0
          coda.imponibile5 = 0
          coda.imponibile_vb1 = 0
          coda.imponibile_vb2 = 0
          coda.imponibile_vb3 = 0
          coda.imponibile_vb4 = 0
          coda.imponibile_vb5 = 0
          coda.importo_sconto = 0
          coda.imposta1 = 0
          coda.imposta2 = 0
          coda.imposta3 = 0
          coda.imposta4 = 0
          coda.imposta5 = 0
          coda.imposta_vb1 = 0
          coda.imposta_vb2 = 0
          coda.imposta_vb3 = 0
          coda.imposta_vb4 = 0
          coda.imposta_vb5 = 0
          coda.totale1 = 0
          coda.totale2 = 0
          coda.totale3 = 0
          coda.totale4 = 0
          coda.totale5 = 0
          coda.totale_vb1 = 0
          coda.totale_vb2 = 0
          coda.totale_vb3 = 0
          coda.totale_vb4 = 0
          coda.totale_vb5 = 0
        end
      end
    end

    noko = Nokogiri::XML::Document.new
    noko.encoding = 'UTF-8'
    noko.root = ric_fisc.to_xml

    noko
  end

  def filename
    "#{created_at.strftime('%Y%m%d_%H%M%S')}_#{identifier}"
  end

  def full_filename
    File.join(Rails.application.config.acao.onda_import_dir, "#{filename}.xml")
  end

  def full_filename_reject
    File.join(Rails.application.config.acao.onda_import_dir, '_importati', "#{filename}_scarti.xml0")
  end

  def full_filename_okay
    File.join(Rails.application.config.acao.onda_import_dir, '_importati', "#{filename}.xml0")
  end

  def send!(no_reg: false, force: false)
    raise "Cannot export in state #{state}" if state != 'PENDING' && !force

    full_filename_new = full_filename + '.new'

    begin
      File.open(full_filename_new , 'w') do |file|
        file.write(build_xml_for_onda_fattura(no_reg: no_reg))
      end

      File.rename(full_filename_new, full_filename)
    ensure
      File.unlink(full_filename_new) rescue nil
    end

    self.state = 'WAIT_CONFIRM'

    save!
  end

  def pending?
    state == 'WAIT_CONFIRM'
  end

  def check_reject!
    if File.exist?(full_filename)
    else
      if File.exist?(full_filename_okay)
        if File.exist?(full_filename_reject)

          doc = Nokogiri::XML(File.read(full_filename_reject))

          self.reject_cause = doc.at_xpath('//Docu')['Errore']
          self.state = 'REJECTED'
        else
          self.state = 'ACCEPTED'
        end
      else
        self.state = 'VANISHED'
      end

      save!
    end
  end

  def self.check_rejects!
    all.where(state: 'WAIT_CONFIRM').each do |invoice|
      invoice.check_reject!
    end
  end
end

end
end
