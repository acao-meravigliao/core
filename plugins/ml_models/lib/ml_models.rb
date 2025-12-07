#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'ml_models/version'

module Ygg
module Ml

class ModelsEngine < Rails::Engine
  config.ml = ActiveSupport::OrderedOptions.new if !defined? config.ml
  config.ml.default_sender = 'YGGDRA'
  config.ml.email_smtp_pars = {
    hostname: 'localhost',
  }
  config.ml.email_debug = 0
  config.ml.email_disabled = false
  config.ml.email_redirect_to = nil
  config.ml.email_also_bcc = []
  config.ml.sms_disable = false
  config.ml.sms_redirect_to = nil
  config.ml.sms_skebby_debug = 0

  def services
   [
   ]
  end

  config.to_prepare do
    Ygg::Core::Person.class_eval do
      has_many :ml_msgs,
               class_name: '::Ygg::Ml::Msg'
    end
  end
end

end
end
