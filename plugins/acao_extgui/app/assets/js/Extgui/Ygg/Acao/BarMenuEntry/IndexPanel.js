/*
 * Copyright (C) 2017-2018, Daniele Orlandi
 *
 * Author:: Daniele Orlandi <daniele@orlandi.com>
 *
 * License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
 *
 */

Ext.define('Extgui.Ygg.Acao.BarMenuEntry.IndexPanel', {
  extend: 'Extgui.object.index.GridPanelBase',
  requires: [
    'Extgui.Ygg.Acao.Plugin',
    'Ygg.Acao.BarMenuEntry',
    'Ygg.Acao.Pilot',
    'Extgui.Ygg.Core.Person',
  ],

  model: 'Ygg.Acao.BarMenuEntry',

  storeConfig: {
    sorters: {
      property: 'valid_to',
      direction: 'DESC',
    },
  },

  columns: [
   {
    dataIndex: 'descr',
    width: 300,
    filterable: true,
    searchable: true,
   },
   {
    xtype: 'decimalcolumn',
    dataIndex: 'price',
    width: 100,
    tdCls: 'price',
    fmtFixed: 2,
    align: 'right',
    unit: '€',
   },
   {
    xtype: 'checkcolumn',
    dataIndex: 'on_sale',
    filterable: true,
   },
  ],

  actions: [
   {
    name: 'new',
    i18nText: 'extgui.acao.bar_menu_entry.index_panel.action.new',
    iconCls: 'icon-add',
   },
  ],

  initComponent: function() {
    var me = this;

    me.callParent(arguments);
    me.down('checkcolumn').on('beforecheckchange', function() {
      return false;
    });
  },
});
