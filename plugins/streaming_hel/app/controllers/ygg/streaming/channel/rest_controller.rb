#
# Copyright (C) 2012-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Streaming

class Channel::RestController < Ygg::Hel::RestController
  ar_controller_for Channel

  include Ygg::Core::ReplicasController

  member_action :request_deletion

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:name) { show! }
    attribute(:descr) { show! }

    attribute(:replicas_state) { show! }
  end

  view :edit do
    attribute(:agent) do
      show!
    end

    attribute(:variants) do
      show!
    end
  end

  view :player do
    attribute(:variants) do
      show!
    end
  end

  # FIXME XXX Okay, this is ugly as shit, there will be a better way to not require authentication

  skip_before_action :ensure_authenticated_and_authorized!, only: [ :index ]

  def ar_authorize_collection_action(action:)
    params[:action] == 'index' ? false : super
  end

  def ar_auth_required?
    params[:action] == 'index' ? false : super
  end
end

end
end
