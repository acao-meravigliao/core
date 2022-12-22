/*
 * Copyright (C) 2018-2018, Daniele Orlandi
 *
 * Author:: Daniele Orlandi <daniele@orlandi.com>
 *
 * License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
 *
 */

Ext.define('Extgui.Ygg.Acao.Airfield.Circuit.CollectionField', {
  extend: 'Extgui.form.field.CollectionGrid',
  requires: [
    'Extgui.Ygg.Acao.Plugin',
    'Extgui.Ygg.Acao.Airfield',
  ],
  alias: 'widget.acao_airfield_circuits',

  model: 'Ygg.Acao.Airfield.Circuit',

  hideHeaders: false,

  columns: [
   {
    dataIndex: 'name',
    flex: 1,
   },
   {
    dataIndex: 'data',
    flex: 2,
   },
  ],

  form: {
    xtype: 'modelform',
    model: 'Ygg.Acao.Airfield.Circuit.Detail',
    layout: 'anchor',
    padding: 10,
    items: [
// FIXME
     {
      xtype: 'textfield',
      name: 'name',
     },
     {
      xtype: 'textarea',
      name: 'data',
      anchor: '100%',
      height: 300,
     },
    ],
  },

});
