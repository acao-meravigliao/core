/*
 * Copyright (C) 2017-2018, Daniele Orlandi
 *
 * Author:: Daniele Orlandi <daniele@orlandi.com>
 *
 * License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
 *
 */

Ext.define('Extgui.Ygg.Acao.BarMenuEntry.ReferenceField', {
  extend: 'Extgui.form.field.ReferenceField',
  requires: [
    'Extgui.Ygg.Acao.Plugin',
    'Ygg.Acao.BarMenuEntry',
    'Extgui.Ygg.Acao.BarMenuEntry',
    'Extgui.Ygg.Acao.BarMenuEntry.Picker',
  ],
  alias: 'widget.acao_bar_menu_entry',

  extguiObject: 'Extgui.Ygg.Acao.BarMenuEntry',
  pickerClass: 'Extgui.Ygg.Acao.BarMenuEntry.Picker',
});
