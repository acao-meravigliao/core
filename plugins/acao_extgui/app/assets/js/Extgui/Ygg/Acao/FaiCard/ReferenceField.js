/*
 * Copyright (C) 2017-2018, Daniele Orlandi
 *
 * Author:: Daniele Orlandi <daniele@orlandi.com>
 *
 * License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
 *
 */

Ext.define('Extgui.Ygg.Acao.FaiCard.ReferenceField', {
  extend: 'Extgui.form.field.ReferenceField',
  requires: [
    'Extgui.Ygg.Acao.Plugin',
    'Ygg.Acao.FaiCard',
    'Extgui.Ygg.Acao.FaiCard',
    'Extgui.Ygg.Acao.FaiCard.Picker',
  ],
  alias: 'widget.acao_fai_card',

  extguiObject: 'Extgui.Ygg.Acao.FaiCard',
  pickerClass: 'Extgui.Ygg.Acao.FaiCard.Picker',
});
