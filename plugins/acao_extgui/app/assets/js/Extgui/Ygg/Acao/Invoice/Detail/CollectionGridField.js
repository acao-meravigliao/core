/*
 * Copyright (C) 2017-2017, Daniele Orlandi
 *
 * Author:: Daniele Orlandi <daniele@orlandi.com>
 *
 * License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
 *
 */

Ext.define('Extgui.Ygg.Acao.Invoice.Detail.CollectionGridField', {
  extend: 'Extgui.form.field.CollectionGrid',
  requires: [
    'Extgui.Ygg.Acao.Plugin',
    'Extgui.Ygg.Acao.Invoice',
    'Extgui.Ygg.Acao.ServiceType',
  ],
  alias: 'widget.acao_invoice_details_grid',

  model: 'Ygg.Acao.Invoice.Detail',

  hideHeaders: false,

  columns: [
//   {
//    xtype: 'stringtemplatecolumn',
//    dataIndex: 'service_type.symbol',
//    text: 'Simbolo',
//    tpl: '{service_type.symbol}',
//    width: 160,
//   },
//   {
//    xtype: 'stringtemplatecolumn',
//    dataIndex: 'service_type.name',
//    text: 'Servizio',
//    tpl: '{service_type.name}',
//    flex: 1,
//   },
   {
    xtype: 'numbercolumn',
    dataIndex: 'count',
    text: 'Qta',
    precision: 0,
    width: 100,
   },
   {
    dataIndex: 'descr',
    text: 'Descrizione',
    flex: 1,
   },
   {
    xtype: 'decimalcolumn',
    dataIndex: 'price',
    text: 'Prezzo',
    width: 100,
    tdCls: 'price',
    fmtFixed: 2,
    align: 'right',
    unit: '€',
   },
   {
    text: 'Dati',
    dataIndex: 'data',
    flex: 1,
   },
  ],

  dockedItems: [{
    xtype: 'toolbar',
    dock: 'bottom',
    items: [
     {
      xtype: 'component',
      html: '<strong>Totale</strong>',
      flex: 1,
     },
     {
      xtype: 'decimalnumberfield',
      name: 'amount',
      align: 'right',
      fieldCls: 'price',
      width: 100,
      fmtFixed: 2,
      unit: '€',
      readOnly: true,
      isFormField: undefined,
     },
    ],
  }],

  form: {
    xtype: 'modelform',
    model: 'Ygg.Acao.Invoice.Detail',
    layout: 'anchor',
    padding: 10,
    items: [
     {
      xtype: 'numberfield',
      name: 'count',
      width: 200,
     },
     {
      xtype: 'textfield',
      name: 'name',
     },
     {
      xtype: 'textfield',
      name: 'descr',
      anchor: '100%',
     },
     {
      xtype: 'decimalnumberfield',
      name: 'price',
      unit: '€',
      decimalPrecision: 2,
      fieldStyle: 'text-align:right;',
      width: 200,
     },
     {
      xtype: 'textfield',
      name: 'data',
      anchor: '100%',
     },
    ],
  },

  initComponent: function() {
    var me = this;

    me.callParent(arguments);

//    me.getStore().on('datachanged', function() {
//      var totalPrice = Big(0);
//
//      Ext.Array.each(me.getStore().getRange(), function(item) {
//        totalPrice = totalPrice.plus(item.get('price'));
//      });
//
//      me.down('decimalnumberfield[name=total_price]').setValue(totalPrice);
//    });

    // Prevent automatic openuri from controller
    me.on('itemdblclick', function(el, record, item, index, e) {
      e.preventDefault(); return false;
   });
  },



});
