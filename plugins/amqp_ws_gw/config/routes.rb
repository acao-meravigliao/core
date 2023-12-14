#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

Rails.application.routes.draw do
  mount Ygg::AmqpWsGw::Rack => '/vos', internal: true
end
