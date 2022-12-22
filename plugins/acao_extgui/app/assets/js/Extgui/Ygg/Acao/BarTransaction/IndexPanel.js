/*
 * Copyright (C) 2017-2018, Daniele Orlandi
 *
 * Author:: Daniele Orlandi <daniele@orlandi.com>
 *
 * License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
 *
 */

Ext.define('Extgui.Ygg.Acao.BarTransaction.IndexPanel', {
  extend: 'Extgui.object.index.GridPanelBase',
  requires: [
    'Extgui.Ygg.Acao.Plugin',
    'Ygg.Acao.BarTransaction',
    'Ygg.Acao.Pilot',
    'Extgui.Ygg.Core.Person',
  ],

  model: 'Ygg.Acao.BarTransaction',

  storeConfig: {
    sorters: {
      property: 'recorded_at',
      direction: 'DESC',
    },
  },

  columns: [
   {
    xtype: 'datecolumn',
    dataIndex: 'recorded_at',
    width: 200,
    filterable: true,
    format: 'Y-m-d H:i:s',
   },
   {
    xtype: 'stringtemplatecolumn',
    tpl: '{person.first_name} {person.last_name}',
    dataIndex: 'person',
    searchable: true,
    searchIn: [ 'person.first_name', 'person.last_name' ],
    width: 250,
   },
   {
    dataIndex: 'descr',
    width: 300,
    filterable: true,
    searchable: true,
   },
   {
    xtype: 'decimalcolumn',
    dataIndex: 'amount',
    width: 100,
    tdCls: 'price',
    fmtFixed: 2,
    align: 'right',
    unit: '€',
   },
  ],

  actions: [
   {
    name: 'new',
    i18nText: 'extgui.acao.bar_transaction.index_panel.action.new',
    iconCls: 'icon-add',
   },
  ],
});
