/*
 * Copyright (C) 2017-2018, Daniele Orlandi
 *
 * Author:: Daniele Orlandi <daniele@orlandi.com>
 *
 * License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
 *
 */

Ext.define('Extgui.Ygg.Acao.KeyFob.IndexPanel', {
  extend: 'Extgui.object.index.GridPanelBase',
  requires: [
    'Extgui.Ygg.Acao.Plugin',
    'Ygg.Acao.KeyFob',
    'Extgui.Ygg.Core.Person',
  ],

  model: 'Ygg.Acao.KeyFob',

  storeConfig: {
    sorters: {
      property: 'code',
      direction: 'DESC',
    },
  },

  columns: [
   {
    xtype: 'stringtemplatecolumn',
    tpl: '{person.first_name} {person.last_name}',
    dataIndex: 'person',
    searchable: true,
    searchIn: [ 'person.first_name', 'person.last_name' ],
    width: 250,
   },
   {
    dataIndex: 'code',
    width: 200,
    filterable: true,
    searchable: true,
   },
   {
    dataIndex: 'descr',
    flex: 1,
    filterable: true,
    searchable: true,
   },
  ],

  actions: [
   {
    name: 'new',
    i18nText: 'extgui.acao.key_fob.index_panel.action.new',
    iconCls: 'icon-add',
   },
  ],
});
