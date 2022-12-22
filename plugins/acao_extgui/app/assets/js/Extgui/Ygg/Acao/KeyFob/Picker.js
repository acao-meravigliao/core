/*
 * Copyright (C) 2014-2017, Daniele Orlandi
 *
 * Author:: Daniele Orlandi <daniele@orlandi.com>
 *
 * License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
 *
 */

Ext.define('Extgui.Ygg.Acao.KeyFob.Picker', {
  extend: 'Extgui.object.Picker',
  requires: [
    'Extgui.Ygg.Acao.Plugin',
    'Extgui.Ygg.Acao.KeyFob',
    'Extgui.Ygg.Acao.KeyFob.View',
  ],
  alias: 'widget.acao_key_fob_picker',

  extguiObject: 'Extgui.Ygg.Acao.KeyFob',

  searchIn: [ 'key_fob' ],

  defaultSorter: 0,
  sorters: [
   { label: 'Code', sorter: 'code' },
  ],
});

