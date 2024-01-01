# frozen_string_literal: true
#
# Copyright (C) 2016-2023, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'rails_vos/rack'

Rails.application.routes.draw do
  mount RailsVos::Rack => '/vos2', internal: true
end
