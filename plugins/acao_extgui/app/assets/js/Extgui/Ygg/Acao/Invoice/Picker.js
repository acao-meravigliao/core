/*
 * Copyright (C) 2014-2017, Daniele Orlandi
 *
 * Author:: Daniele Orlandi <daniele@orlandi.com>
 *
 * License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
 *
 */

Ext.define('Extgui.Ygg.Acao.Invoice.Picker', {
  extend: 'Extgui.object.Picker',
  requires: [
    'Extgui.Ygg.Acao.Plugin',
    'Extgui.Ygg.Acao.Invoice',
    'Extgui.Ygg.Acao.Invoice.View',
  ],
  alias: 'widget.acao_invoice_picker',

  extguiObject: 'Extgui.Ygg.Acao.Invoice',

  searchIn: [ 'id' ],

  defaultSorter: 0,
  sorters: [
   { label: 'ID', sorter: 'id' },
  ],
});

