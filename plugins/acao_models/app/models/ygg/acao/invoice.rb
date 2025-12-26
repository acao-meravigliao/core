# frozen_string_literal: true
#
# Copyright (C) 2017-2025, Daniele Orlandi
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

  has_one :token_transaction,
          class_name: 'Ygg::Acao::TokenTransaction'

  belongs_to :debt,
             class_name: 'Ygg::Acao::Debt',
             optional: true

  has_many :payments,
           class_name: 'Ygg::Acao::Payment'

  gs_rel_map << { from: :invoice, to: :member, to_cls: 'Ygg::Acao::Member', from_key: 'member_id', }
  gs_rel_map << { from: :invoice, to: :person, to_cls: 'Ygg::Core::Person', from_key: 'person_id', }
  gs_rel_map << { from: :invoice, to: :debt, to_cls: 'Ygg::Acao::Debt', from_key: 'debt_id', }
  gs_rel_map << { from: :invoice, to: :payment, to_cls: 'Ygg::Acao::Payment', to_key: 'invoice_id', }
  gs_rel_map << { from: :invoice, to: :detail, to_cls: 'Ygg::Acao::Invoice::Detail', to_key: 'invoice_id', }
  gs_rel_map << { from: :invoice, to: :token_transaction, to_cls: 'Ygg::Acao::TokenTransaction', to_key: 'invoice_id', }

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
      debt = Ygg::Acao::Debt.find_by(identifier: l.NostroRif) ||
             Ygg::Acao::Debt.find_by(identifier: l.NostroRif[0...5])

      puts "  DEBT = #{debt ? debt.identifier : 'nil'}"
      puts "  PAYMENTS = #{debt ? (debt.payments.map { |x| x.identifier }) : 'nil'}"

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
        our_reference: l.NostroRif,
        debt: debt,
        payments: debt ? debt.payments : [],
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
      end

      # TODO: Associate TokenTransactions with this invoice
      ##tt = Ygg::Acao::TokenTransaction.where('recorded_at BETWEEN ? AND ?',
      ##       invoice.recorded_at.beginning_of_year, invoice.recorded_at.ending_of_year).where('descr LIKE \'%?%\'', invoice.identifier)

      # TODO: Associate MemberService with this invoice

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
      debt = Ygg::Acao::Debt.find_by(identifier: l.NostroRif) ||
             Ygg::Acao::Debt.find_by(identifier: l.NostroRif[0...5])

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
        our_reference: l.NostroRif,
        debt: debt,
        payments: debt ? debt.payments : [],
      )

      # TODO: Associate TokenTransactions with this invoice
      # TODO: Associate MemberService with this invoice

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

  idxc_cached
  self.idxc_sensitive_attributes = [
    :person_id,
  ]

  def total
    details.reduce(0) { |a,x| a + x.price }
  end

end

end
end
