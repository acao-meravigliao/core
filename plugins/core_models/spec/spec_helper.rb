#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'rails/all'

ENV["RAILS_ENV"] = "test"
#require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'rspec/rails'

module Railsspec
  class Application < Rails::Application
    config.cookie_secret = 'cd8218037e4306507bae2a8581a343641729c32410a1294f205914a84cbe738028a06dbe3a9ef3ad025831c7a4cc9bd099444933a7ee584df3fb250c168abb26'
config.session_store :cookie_store, {
  :key => '_railsspec_session',
}

  end
end


Railsspec::Application.initialize!
