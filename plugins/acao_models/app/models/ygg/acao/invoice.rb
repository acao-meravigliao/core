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

class Invoice < Ygg::PublicModel
  self.table_name = 'acao.invoices'

  has_meta_class

  belongs_to :member,
             class_name: 'Ygg::Acao::Member',
             optional: true

  belongs_to :person,
             class_name: 'Ygg::Core::Person',
             optional: true

  has_many :details,
           class_name: 'Ygg::Acao::Invoice::Detail',
           embedded: true,
           dependent: :destroy,
           autosave: true

  gs_rel_map << { from: :invoice, to: :member, to_cls: 'Ygg::Acao::Member', from_key: 'member_id', }
  gs_rel_map << { from: :invoice, to: :person, to_cls: 'Ygg::Core::Person', from_key: 'person_id', }
  gs_rel_map << { from: :invoice, to: :detail, to_cls: 'Ygg::Acao::Invoice::Detail', to_key: 'invoice_id', }

#  has_many :payments,
#           class_name: 'Ygg::Acao::Payment'

  include Ygg::Core::Loggable
  define_default_log_controller(self)

  include Ygg::Core::Notifiable

  DOC_TYPES = {
    4 => 'invoice',
    5 => 'nota_credito',
    6 => 'receipt',
  }

  def self.sync_from_maindb!(from_time: nil, start: nil, stop: nil, force: false, debug: 0)
    if from_time
      ff = Ygg::Acao::Onda::DocTesta.order(DataDocumento: :asc).where('DataDocumento > ?', from_time).first
      return if !ff
      start = ff.IdDoc
    end

    if start && debug >= 1
      puts "Start = #{start}"
    end

    l_relation = Ygg::Acao::Onda::DocTesta.all.where(TipoDocumento: [4,6]).order(IdDoc: :asc)
    l_relation = l_relation.where('IdDoc >= ?', start) if start
    l_relation = l_relation.where('IdDoc <= ?', stop) if stop

    r_relation = Ygg::Acao::Invoice.
                   includes(:details).
                   where('source_id IS NOT NULL').
                   order(source_id: :asc)
    r_relation = r_relation.where('source_id >= ?', start) if start
    r_relation = r_relation.where('source_id <= ?', stop) if stop

    Ygg::Toolkit.merge(
    l: l_relation,
    r: r_relation,
    l_cmp_r: lambda { |l,r| l.IdDoc <=> r.source_id },
    l_to_r: lambda { |l|
      puts "INVOICE ADD #{l.IdDoc} #{l.NumeroDocumento}" if debug >= 1

      anagrafica = l.anagrafica
      anagrafica_cliente = l.anagrafica_cliente
      mdb_socio = Ygg::Acao::MainDb::Socio.find_by(codice_socio_dati_generale: anagrafica_cliente.RifInterno)
      member = mdb_socio ? Ygg::Acao::Member.find_by!(ext_id: mdb_socio.id_soci_dati_generale) : nil
      year = l.DataDocumento.year

      invoice = Ygg::Acao::Invoice.new(
        member: member,
        person: member && member.person,
        source_id: l.IdDoc,
        year: year,
        identifier: l.NumeroDocumento,
        identifier_full: l.Riferimento,
        document_type: l.TipoDocumento,
        document_date: l.DataDocumento,
        registered_at: l.DataRegistrazione,
        payment_method: l.CodPagamento,
        recipient: anagrafica.RagioneSociale,
        address: [ anagrafica.Indirizzo, anagrafica.Cap, anagrafica.Citta, anagrafica.Provincia, anagrafica.CodNazione ].compact.join(','),
        codice_fiscale: anagrafica.CodiceFiscale,
        partita_iva: anagrafica.PartitaIva,
        email: anagrafica.E_mail,
        amount: l.TotDocumento,
      )

      l.righe.each do |riga|
        invoice.details.build(
          row_type: riga.TipoRiga,
          row_number: riga.NrRiga,
          code: riga.CodArt,
          count: riga.Qta,
          single_amount: riga.ValoreUnitario,
          untaxed_amount: riga.Imponibile,
          vat_amount: riga.Imposta,
          total_amount: riga.Totale,
          descr: riga.Descrizione,
        )

        invoice.save!
      end

      invoice.save!
    },
    r_to_l: lambda { |r|
      puts "INVOICE DESTROY #{r.source_id} #{r.identifier}" #if debug >= 1
      r.destroy!
    },
    lr_update: lambda { |l,r|
      puts "INVOICE CMP #{l.IdDoc} #{l.NumeroDocumento}" if debug >= 3

      anagrafica = l.anagrafica
      anagrafica_cliente = l.anagrafica_cliente
      mdb_socio = Ygg::Acao::MainDb::Socio.find_by(codice_socio_dati_generale: anagrafica_cliente.RifInterno)
      member = mdb_socio ? Ygg::Acao::Member.find_by!(ext_id: mdb_socio.id_soci_dati_generale) : nil
      year = l.DataDocumento.year

      r.assign_attributes(
        member: member,
        person: member && member.person,
        year: year,
        identifier: l.NumeroDocumento,
        identifier_full: l.Riferimento,
        document_type: l.TipoDocumento,
        document_date: l.DataDocumento,
        registered_at: l.DataRegistrazione,
        payment_method: l.CodPagamento,
        recipient: anagrafica.RagioneSociale,
        address: [ anagrafica.Indirizzo, anagrafica.Cap, anagrafica.Citta, anagrafica.Provincia, anagrafica.CodNazione ].compact.join(','),
        codice_fiscale: anagrafica.CodiceFiscale,
        partita_iva: anagrafica.PartitaIva,
        email: anagrafica.E_mail,
        amount: l.TotDocumento,
      )

      if r.deep_changed? || force
        r.details.destroy_all
        l.righe.each do |riga|
          r.details.create(
            row_type: riga.TipoRiga,
            row_number: riga.NrRiga,
            code: riga.CodArt,
            count: riga.Qta,
            single_amount: riga.ValoreUnitario,
            untaxed_amount: riga.Imponibile,
            vat_amount: riga.Imposta,
            total_amount: riga.Totale,
            descr: riga.Descrizione,
          )
        end

        puts "INVOICE CHANGED #{l.IdDoc} #{l.NumeroDocumento}" if debug >= 1
        puts r.deep_changes.awesome_inspect(plain: true)
        r.save!
      end
    })

  end

#  after_initialize do
#    if new_record?
#      if person
#        self.first_name = person.first_name
#        self.last_name = person.last_name
#        self.address = person.residence_location && person.residence_location.full_address
#      end
#
#      assign_identifier!
#    end
#  end

  idxc_cached
  self.idxc_sensitive_attributes = [
    :person_id,
  ]

#  def assign_identifier!
#    identifier = nil
#
#    loop do
#      identifier = "I-" + Password.random(length: 4, symbols: 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789')
#      break if !self.class.find_by_identifier(identifier)
#    end
#
#    self.identifier = identifier
#  end

  def total
    details.reduce(0) { |a,x| a + x.price }
  end

#  def close!
#    self.state = 'CLOSED'
#    save!
#  end

#  def one_payment_has_been_completed!(payment)
#    if payments.all? { |x| x.state == 'COMPLETED' }
#      paid_in_full!
#    else
#      self.payment_state = 'PARTIALLY_PAID'
#      save!
#    end
#  end
#
#  def paid_in_full!
#    self.payment_state = 'PAID_IN_FULL'
#    save!
#
#    details.all.each do |detail|
#      detail.membership.payment_completed!  if detail.membership
#      detail.member_service.payment_completed!  if detail.member_service
#
#      if detail.service_type.symbol == 'SKYSIGHT'
#        Ygg::Acao::SkysightCode.assign_and_send!(person: person)
#      end
#    end
#
#    if onda_export_status == nil
#      self.onda_export_status = 'PENDING'
#      save!
#
#      export_to_onda!
#    end
#  end
#
#  def generate_payment!(reason: "Pagamento fattura", timeout: 10.days)
#    Ygg::Acao::Payment.create(
#      person: person,
#      invoice: self,
#      created_at: Time.now,
#      expires_at: Time.now + timeout,
#      payment_method: payment_method,
#      reason_for_payment: reason,
#      amount: total,
#    )
#  end

  PAYMENT_METHOD_MAP = {
    'WIRE'      => 'BB',
    'CHECK'     => 'AS',
    'SATISPAY'  => 'SP',
    'CARD'      => 'CC',
    'CASH'      => 'CO',
  }

end

end
end
