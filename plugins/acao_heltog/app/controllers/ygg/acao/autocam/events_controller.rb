#
# Copyright (C) 2017-2022, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao
module Autocam

class EventsController < HelTogether::Controller

  def event
logger.info "AAAAAAAAAAAAAAAAAAAAAAAAAAAAa #{payload.inspect}"
logger.info "AAAAAAAAAAAAAAAAAAAAAAAAAAAAb #{headers.inspect}"

#    Ygg::Acao::AutoCam::CameraEvent.create!(
#      event_type: headers[:type],
#      ts: Time.now, #headers[:
#      aircraft_id: payload[:traffic_id],
#      name: payload[:name],
#      flarm_id: payload[:flarm_id],
#      lat: payload[:lat],
#      lng: payload[:lng],
#      alt: payload[:alt],
#      hgt: payload[:hgt],
#    )

    return_from_action true
  end
end

end
end
end
