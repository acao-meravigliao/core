/*
 * Copyright (C) 2014-2018, Daniele Orlandi
 *
 * Author:: Daniele Orlandi <daniele@orlandi.com>
 *
 * License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
 *
 */

Ext.define('Extgui.Ygg.Acao.FaiCard.Picker', {
  extend: 'Extgui.object.Picker',
  requires: [
    'Extgui.Ygg.Acao.Plugin',
    'Extgui.Ygg.Acao.FaiCard',
    'Extgui.Ygg.Acao.FaiCard.View',
  ],
  alias: 'widget.acao_fai_card_picker',

  extguiObject: 'Extgui.Ygg.Acao.FaiCard',

  searchIn: [ 'fai_card' ],

  defaultSorter: 0,
  sorters: [
   { label: 'Identifier', sorter: 'identifier' },
  ],
});

