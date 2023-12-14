#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require "ca_models/version"

module Ygg
module Ca

class ModelsEngine < Rails::Engine
  config.ca = ActiveSupport::OrderedOptions.new if !defined? config.ca
  config.ca.le_account = 'DEFAULT'
  config.ca.le_http_debug = 0

  def services
   [
    'Ygg::Ca::Certificate'
   ]
  end
end

end
end
