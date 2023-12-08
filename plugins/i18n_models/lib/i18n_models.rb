#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'i18n_models/version'
#require 'i18n/core_ext/hash'

module Ygg
module I18n

class ModelsEngine < Rails::Engine
  config.i18n_backend = ActiveSupport::OrderedOptions.new if !defined? config.i18n
  config.i18n_backend.enabled = true

  def services
   [
   ]
  end

  initializer 'rails_i18n.configure_rails_initialization' do
    if Rails.application.config.i18n_backend.enabled
      Rails.application.reloader.to_prepare do
        Ygg::I18n::Backend
        ::I18n.backend = ::I18n::Backend::Chain.new(Ygg::I18n::Backend.new, ::I18n.backend)
      end
    end
  end
end

end
end
