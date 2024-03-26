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
# {:id=>"club_tour", :name=>"ACAO Tour", :interest=>0}
# {:content_type=>"application/json", :delivery_mode=>2, :priority=>0, :timestamp=>1643979581, :type=>"CAM_TARGET_STOP"}
#
#
# {:id=>"6df15506-da20-41ba-9a3b-160cedb0ef3e", :name=>"D-2155", :interest=>40, :lat=>45.80895716759367, :lng=>8.77205433053044, :cog=>90, :tr=>0, :sog=>1.0269910654095578, :acc=>nil, :alt=>239.5, :hgt=>-11.5, :cr=>-0.1, :dist=>nil, :size=>26, :registration=>"D-2155", :flarm_type=>1, :flarm_id=>"DF0879", :flarm_last_rep=>nil, :tow_state=>nil, :flying_state=>"on_land", :freshness=>0.9810958496}
# {:content_type=>"application/json", :delivery_mode=>2, :priority=>0, :timestamp=>1643979581, :type=>"CAM_TARGET_START"}

begin
    Ygg::Acao::Autocam::CameraEvent.create!(
      event_type: headers[:type],
      ts: Time.at(headers[:timestamp]),
      aircraft_id: payload[:aircraft_id],
      name: payload[:name],
      flarm_id: payload[:flarm_id],
      lat: payload[:lat],
      lng: payload[:lng],
      alt: payload[:alt],
      hgt: payload[:hgt],
      data: {}
    )
rescue StandardError => e
logger.warn e
end

    return_from_action true
  end
end

end
end
end
