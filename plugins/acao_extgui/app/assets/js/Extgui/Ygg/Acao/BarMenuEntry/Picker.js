/*
 * Copyright (C) 2014-2018, Daniele Orlandi
 *
 * Author:: Daniele Orlandi <daniele@orlandi.com>
 *
 * License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
 *
 */

Ext.define('Extgui.Ygg.Acao.BarMenuEntry.Picker', {
  extend: 'Extgui.object.Picker',
  requires: [
    'Extgui.Ygg.Acao.Plugin',
    'Extgui.Ygg.Acao.BarMenuEntry',
    'Extgui.Ygg.Acao.BarMenuEntry.View',
  ],
  alias: 'widget.acao_bar_menu_entry_picker',

  extguiObject: 'Extgui.Ygg.Acao.BarMenuEntry',

  searchIn: [ 'bar_menu_entry' ],

  defaultSorter: 0,
  sorters: [
   { label: 'Descr', sorter: 'descr' },
  ],
});

