#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Hel

# Base controller that ensures that there is a valid, authenticated and authorized session
#
class AuthenticatedController < BaseController

  before_action :ensure_authenticated_and_authorized!, :except => [ :get_schema ]

  def ensure_authenticated_and_authorized!
    super

    unless (aaa_context.global_roles & Set.new([ :superuser, :api, :simple_interface, :full_interface ])).any?
      raise RailsActiveRest::Controller::AuthorizationError.new(
              title: 'You do not have the required role',
              title_sym: 'You do not have the required role')
    end
  end

end

end
end
