/*
 * Copyright (C) 2016-2017, Daniele Orlandi
 *
 * Author:: Daniele Orlandi <daniele@orlandi.com>
 *
 * License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
 *
 */

Ext.define('Extgui.Ygg.Acao.Gate.IndexPanel', {
  extend: 'Extgui.object.index.GridPanelBase',
  requires: [
    'Extgui.Ygg.Acao.Plugin',
    'Ygg.Acao.Gate',
    'Ext.grid.column.Date',
    'Ygg.Core.Person',
  ],
  model: 'Ygg.Acao.Gate',
  storeConfig: {
    sorters: {
      property: 'name',
      direction: 'ASC',
    },
  },
  columns: [
   {
    dataIndex: 'name',
    filterable: true,
    searchable: true,
    flex: 1,
   },
   {
    dataIndex: 'descr',
    filterable: true,
    searchable: true,
    flex: 2,
   },
  ],
  actions: [
   {
    name: 'new',
    i18nText: 'extgui.acao.gate.index_panel.action.new',
    iconCls: 'icon-add',
   }
  ],
});
