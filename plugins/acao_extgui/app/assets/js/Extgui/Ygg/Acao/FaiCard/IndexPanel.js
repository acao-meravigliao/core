/*
 * Copyright (C) 2017-2018, Daniele Orlandi
 *
 * Author:: Daniele Orlandi <daniele@orlandi.com>
 *
 * License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
 *
 */

Ext.define('Extgui.Ygg.Acao.FaiCard.IndexPanel', {
  extend: 'Extgui.object.index.GridPanelBase',
  requires: [
    'Extgui.Ygg.Acao.Plugin',
    'Ygg.Acao.FaiCard',
    'Ygg.Acao.Pilot',
    'Extgui.Ygg.Core.Person',
  ],

  model: 'Ygg.Acao.FaiCard',

  storeConfig: {
    sorters: {
      property: 'valid_to',
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
    dataIndex: 'identifier',
    width: 200,
    filterable: true,
    searchable: true,
   },
   {
    dataIndex: 'country',
    width: 200,
    filterable: true,
    searchable: true,
   },
   {
    xtype: 'datecolumn',
    dataIndex: 'issued_at',
    width: 100,
    filterable: true,
    searchable: true,
   },
   {
    xtype: 'datecolumn',
    dataIndex: 'valid_to',
    width: 100,
    filterable: true,
    searchable: true,
   },
  ],

  actions: [
   {
    name: 'new',
    i18nText: 'extgui.acao.fai_card.index_panel.action.new',
    iconCls: 'icon-add',
   },
  ],
});
