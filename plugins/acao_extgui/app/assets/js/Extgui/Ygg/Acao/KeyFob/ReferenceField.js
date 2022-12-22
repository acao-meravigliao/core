/*
 * Copyright (C) 2017-2018, Daniele Orlandi
 *
 * Author:: Daniele Orlandi <daniele@orlandi.com>
 *
 * License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
 *
 */

Ext.define('Extgui.Ygg.Acao.KeyFob.ReferenceField', {
  extend: 'Extgui.form.field.ReferenceField',
  requires: [
    'Extgui.Ygg.Acao.Plugin',
    'Ygg.Acao.KeyFob',
    'Extgui.Ygg.Acao.KeyFob',
    'Extgui.Ygg.Acao.KeyFob.Picker',
  ],
  alias: 'widget.acao_key_fob',

  extguiObject: 'Extgui.Ygg.Acao.KeyFob',
  pickerClass: 'Extgui.Ygg.Acao.KeyFob.Picker',
});
