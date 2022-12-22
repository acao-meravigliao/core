/*
 * Copyright (C) 2014-2017, Daniele Orlandi
 *
 * Author:: Daniele Orlandi <daniele@orlandi.com>
 *
 * License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
 *
 */

Ext.define('Extgui.Ygg.Acao.Membership.Picker', {
  extend: 'Extgui.object.Picker',
  requires: [
    'Extgui.Ygg.Acao.Plugin',
    'Extgui.Ygg.Acao.Membership',
    'Extgui.Ygg.Acao.Membership.View',
  ],
  alias: 'widget.acao_membership_picker',

  extguiObject: 'Extgui.Ygg.Acao.Membership',

  searchIn: [ 'membership' ],

  defaultSorter: 0,
  sorters: [
   { label: 'Valid From', sorter: 'valid_from' },
   { label: 'Valid To', sorter: 'valid_to' },
  ],
});

