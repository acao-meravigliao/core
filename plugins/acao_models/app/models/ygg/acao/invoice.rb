#
# Copyright (C) 2017-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Invoice < Ygg::PublicModel
  self.table_name = 'acao.invoices'

  self.porn_migration += [
    [ :must_have_column, {name: "id", type: :uuid, null: false, default_function: 'gen_random_uuid()' }],
    [ :must_have_column, {name: "identifier", type: :string, default: nil, limit: 16, null: true}],
    [ :must_have_column, {name: "person_id", type: :integer, default: nil, limit: 4, null: false}],
    [ :must_have_column, {name: "first_name", type: :string, default: nil, limit: 255, null: true}],
    [ :must_have_column, {name: "last_name", type: :string, default: nil, limit: 255, null: true}],
    [ :must_have_column, {name: "address", type: :string, default: nil, limit: 255, null: true}],
    [ :must_have_column, {name: "created_at", type: :datetime, default: nil, null: true}],
    [ :must_have_column, {name: "state", type: :string, default: 'NEW', null: false}],
    [ :must_have_column, {name: "payment_state", type: :string, default: 'UNPAID', null: false}],
    [ :must_have_column, {name: "notes", type: :text, default: nil, null: true}],
    [ :must_have_column, {name: "payment_method", type: :string, default: nil, limit: 32, null: false}],
    [ :must_have_column, {name: "last_chore", type: :datetime, default: nil, null: true}],
    [ :must_have_column, {name: "onda_export_status", type: :string, default: nil, limit: 32, null: true}],
    [ :must_have_index, {columns: ["identifier"], unique: true}],
    [ :must_have_index, {columns: ["person_id"], unique: false}],
    [ :must_have_fk, {to_table: "core_people", column: "person_id", primary_key: "id", on_delete: nil, on_update: nil}],
  ]

  has_meta_class

  belongs_to :person,
             class_name: 'Ygg::Core::Person'

  has_many :details,
           class_name: 'Ygg::Acao::Invoice::Detail',
           embedded: true,
           dependent: :destroy,
           autosave: true

  has_many :payments,
           class_name: 'Ygg::Acao::Payment'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  include Ygg::Core::Notifiable

  # TO BE REMOVED WHEN ALL IDs are UUIDs
  has_many :readables,
           class_name: 'Ygg::Core::ReadableUuid',
           as: :obj

  def self.readables_relation(person_id:)
    joins(:readables).where(core_readables_uuid: { person_id: person_id })
  end
  ########################################### ^^^^^^^^^

  after_initialize do
    if new_record?
      if person
        self.first_name = person.first_name
        self.last_name = person.last_name
        self.address = person.residence_location && person.residence_location.full_address
      end

      assign_identifier!
    end
  end

  idxc_cached
  self.idxc_sensitive_attributes = [
    :person_id,
  ]

  def assign_identifier!
    identifier = nil

    loop do
      identifier = "I-" + Password.random(length: 4, symbols: 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789')
      break if !self.class.find_by_identifier(identifier)
    end

    self.identifier = identifier
  end

  def total
    details.reduce(0) { |a,x| a + x.price }
  end

  def close!
    self.state = 'CLOSED'
    save!
  end

  def one_payment_has_been_completed!(payment)
    if payments.all? { |x| x.state == 'COMPLETED' }
      paid_in_full!
    else
      self.payment_state = 'PARTIALLY_PAID'
      save!
    end
  end

  def paid_in_full!
    self.payment_state = 'PAID_IN_FULL'
    save!

    details.all.each do |detail|
      detail.membership.payment_completed!  if detail.membership
      detail.member_service.payment_completed!  if detail.member_service

      if detail.service_type.symbol == 'SKYSIGHT'
        Ygg::Acao::SkysightCode.assign_and_send!(person: person)
      end
    end

    if onda_export_status == nil
      self.onda_export_status = 'PENDING'
      save!

      export_to_onda!
    end
  end

  def generate_payment!(reason: "Pagamento fattura", timeout: 10.days)
    Ygg::Acao::Payment.create(
      person: person,
      invoice: self,
      created_at: Time.now,
      expires_at: Time.now + timeout,
      payment_method: payment_method,
      reason_for_payment: reason,
      amount: total,
    )
  end

  def self.check_rejects!
    all.where(onda_export_status: 'EXPORTED').each do |invoice|
      invoice.check_reject!
    end
  end

  def self.run_chores!
    check_rejects!

#    all.each do |invoice|
#      invoice.run_chores!
#    end
  end
#
#  def run_chores!
#    transaction do
#      now = Time.now
#      last_run = last_chore || Time.new(0)
#
#      self.last_chore = now
#
#      save!
#    end
#  end

  PAYMENT_METHOD_MAP = {
    'WIRE'      => 'BB',
    'CHECK'     => 'AS',
    'SATISPAY'  => 'SP',
    'CARD'      => 'CC',
    'CASH'      => 'CO',
  }

  def build_xml_for_onda_fattura
    cod_pagamento = PAYMENT_METHOD_MAP[payment_method.upcase]

    ric_fisc = XmlInterface::RicFisc.new do |ric_fisc|
      ric_fisc.cod_schema = 'ACAOFATT'
      ric_fisc.data_ora_creazione = Time.now
      ric_fisc.docus[0] = XmlInterface::RicFisc::Docu.new do |docu|
        docu.testa = XmlInterface::RicFisc::Docu::Testa.new do |testa|
          testa.abbuono = 0
          testa.acconto = 0
          testa.acconto_in_cassa = true
          testa.calcoli_su_imponibile = false
          testa.cod_divisa = 'EUR'
          testa.cod_pagamento = cod_pagamento
          testa.commento = onda_no_reg ? 'NO-REG' : ''
          testa.contrassegno = 0
          testa.nostro_rif = identifier
          testa.tot_documento = 0
          testa.tot_imponibile = 0
          testa.tot_imposta = 0
          testa.vostro_rif = identifier
          testa.dati_controparte = XmlInterface::RicFisc::Docu::Testa::DatiControparte.new
          testa.dati_controparte.citta = person.residence_location.city
          testa.dati_controparte.codice_fiscale = person.italian_fiscal_code || person.vat_number
          testa.dati_controparte.e_mail = person.contacts.where(type: 'email').first.value
          testa.dati_controparte.indirizzo = person.residence_location.full_address
          testa.dati_controparte.partita_iva = person.vat_number || ''
          testa.dati_controparte.ragione_sociale = person.name
        end

        docu.righe = XmlInterface::RicFisc::Docu::Righe.new do |righe|
          details.each do |det|
            if det.service_type.onda_1_type && det.service_type.onda_1_code
              righe.righe << XmlInterface::RicFisc::Docu::Righe::Riga.new do |riga|
                riga.cod_art = det.service_type.onda_1_code
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
                riga.qta = det.service_type.onda_1_cnt
                riga.tipo_riga = det.service_type.onda_1_type
                riga.totale = ''
                riga.valore_unitario = ''

                riga.dati_art_serv = XmlInterface::RicFisc::Docu::Righe::Riga::DatiArtServ.new do |dati_art_serv|
                  dati_art_serv.cod_art = det.service_type.onda_1_code
                  dati_art_serv.cod_un_mis_base = 'NR.'
                  dati_art_serv.descrizione = det.data ? "#{det.descr} #{det.data}" : ''
                  dati_art_serv.tipo_articolo = det.service_type.onda_1_type
                end
              end
            end

            if det.service_type.onda_2_type && det.service_type.onda_2_code
              righe.righe << XmlInterface::RicFisc::Docu::Righe::Riga.new do |riga|
                riga.cod_art = det.service_type.onda_2_code
                riga.cod_iva = ''
                riga.cod_un_mis = 'NR.'
                riga.descrizione = ''
                riga.imponibile = ''
                riga.importo_sconto = 0
                riga.imposta = ''
                riga.perc_sconto1 = 0
                riga.perc_sconto2 = 0
                riga.perc_sconto3 = 0
                riga.perc_sconto4 = 0
                riga.qta = det.service_type.onda_2_cnt
                riga.tipo_riga = det.service_type.onda_2_type
                riga.totale = ''
                riga.valore_unitario = ''

                riga.dati_art_serv = XmlInterface::RicFisc::Docu::Righe::Riga::DatiArtServ.new do |dati_art_serv|
                  dati_art_serv.cod_art = det.service_type.onda_2_code
                  dati_art_serv.cod_un_mis_base = 'NR.'
                  dati_art_serv.descrizione = ''
                  dati_art_serv.tipo_articolo = det.service_type.onda_2_type
                end
              end
            end
          end

          righe.righe << XmlInterface::RicFisc::Docu::Righe::Riga.new do |riga|
            riga.cod_art = ''
            riga.cod_iva = ''
            riga.cod_un_mis = ''
            riga.descrizione = "Acquisto online, codice interno ricevuta #{identifier}"
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

  def build_xml_for_onda_ricevuta
    cod_pagamento = PAYMENT_METHOD_MAP[payment_method.upcase]

    ric_fisc = XmlInterface::RicFisc.new do |ric_fisc|
      ric_fisc.cod_schema = 'RICFISC1'
      ric_fisc.data_ora_creazione = Time.now
      ric_fisc.docus[0] = XmlInterface::RicFisc::Docu.new do |docu|
        docu.testa = XmlInterface::RicFisc::Docu::Testa.new do |testa|
          testa.abbuono = 0
          testa.acconto = 0
          testa.acconto_in_cassa = true
          testa.calcoli_su_imponibile = false
          testa.cod_divisa = 'EUR'
          testa.cod_pagamento = cod_pagamento
          testa.commento = onda_no_reg ? 'NO-REG' : ''
          testa.contrassegno = 0
          testa.nostro_rif = identifier
          testa.tot_documento = 0
          testa.tot_imponibile = 0
          testa.tot_imposta = 0
          testa.vostro_rif = identifier
          testa.dati_controparte = XmlInterface::RicFisc::Docu::Testa::DatiControparte.new
          testa.dati_controparte.citta = person.residence_location.city
          testa.dati_controparte.codice_fiscale = person.italian_fiscal_code || person.vat_number
          testa.dati_controparte.e_mail = person.contacts.where(type: 'email').first.value
          testa.dati_controparte.indirizzo = person.residence_location.full_address
          testa.dati_controparte.partita_iva = person.vat_number || ''
          testa.dati_controparte.ragione_sociale = person.name
        end

        docu.righe = XmlInterface::RicFisc::Docu::Righe.new do |righe|
          details.each do |det|
            if det.service_type.onda_1_type && det.service_type.onda_1_code
              righe.righe << XmlInterface::RicFisc::Docu::Righe::Riga.new do |riga|
                riga.cod_art = det.service_type.onda_1_code
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
                riga.qta = det.service_type.onda_1_cnt
                riga.tipo_riga = det.service_type.onda_1_type
                riga.totale = ''
                riga.valore_unitario = ''

                riga.dati_art_serv = XmlInterface::RicFisc::Docu::Righe::Riga::DatiArtServ.new do |dati_art_serv|
                  dati_art_serv.cod_art = det.service_type.onda_1_code
                  dati_art_serv.cod_un_mis_base = 'NR.'
                  dati_art_serv.descrizione = det.data ? "#{det.descr} #{det.data}" : ''
                  dati_art_serv.tipo_articolo = det.service_type.onda_1_type
                end
              end
            end

            if det.service_type.onda_2_type && det.service_type.onda_2_code
              righe.righe << XmlInterface::RicFisc::Docu::Righe::Riga.new do |riga|
                riga.cod_art = det.service_type.onda_2_code
                riga.cod_iva = ''
                riga.cod_un_mis = 'NR.'
                riga.descrizione = ''
                riga.imponibile = ''
                riga.importo_sconto = 0
                riga.imposta = ''
                riga.perc_sconto1 = 0
                riga.perc_sconto2 = 0
                riga.perc_sconto3 = 0
                riga.perc_sconto4 = 0
                riga.qta = det.service_type.onda_2_cnt
                riga.tipo_riga = det.service_type.onda_2_type
                riga.totale = ''
                riga.valore_unitario = ''

                riga.dati_art_serv = XmlInterface::RicFisc::Docu::Righe::Riga::DatiArtServ.new do |dati_art_serv|
                  dati_art_serv.cod_art = det.service_type.onda_2_code
                  dati_art_serv.cod_un_mis_base = 'NR.'
                  dati_art_serv.descrizione = ''
                  dati_art_serv.tipo_articolo = det.service_type.onda_2_type
                end
              end
            end
          end

          righe.righe << XmlInterface::RicFisc::Docu::Righe::Riga.new do |riga|
            riga.cod_art = ''
            riga.cod_iva = ''
            riga.cod_un_mis = ''
            riga.descrizione = "Acquisto online, codice interno ricevuta #{identifier}"
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

  def export_to_onda!(force: false)
    raise "Cannot export in onda_export_status #{onda_export_status}" if onda_export_status != 'PENDING' && !force

    fileid = "#{Time.now.strftime('%Y%m%d_%H%M%S')}_#{identifier}"

    filename = File.join(Rails.application.config.acao.onda_import_dir, "#{fileid}.xml")
    filename_new = filename + '.new'

    begin
      File.open(filename_new , 'w') do |file|
        file.write(build_xml_for_onda_fattura)
      end

      File.rename(filename_new, filename)
    ensure
      File.unlink(filename_new) rescue nil
    end

    self.onda_export_filename = fileid
    self.onda_export_status = 'EXPORTED'
    save!
  end

  def check_reject!
    filename_reject = File.join(Rails.application.config.acao.onda_import_dir, '_importati',
                                "#{onda_export_filename}_scarti.xml0")
    filename_okay = File.join(Rails.application.config.acao.onda_import_dir, '_importati',
                                "#{onda_export_filename}.xml0")

    if File.exist?(filename_okay)
      if File.exist?(filename_reject)
        self.onda_export_status = 'REJECTED'
      else
        self.onda_export_status = 'ACCEPTED'
      end

      save!
    end
  end
end

end
end
