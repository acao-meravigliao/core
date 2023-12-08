#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class Location < Ygg::BasicModel

  self.table_name = 'core.locations'

  self.porn_migration += [
    [ :must_have_column, { name: 'id', type: :uuid, null: false, default_function: 'gen_random_uuid()' } ],
    [ :must_have_column, { name: 'city', type: :string, limit: 64 } ],
    [ :must_have_column, { name: 'state', type: :string, limit: 64 } ],
    [ :must_have_column, { name: 'country_code', type: :string, limit: 2 } ],
    [ :must_have_column, { name: 'zip', type: :string, limit: 12 } ],
    [ :must_have_column, { name: 'lat', type: :float } ],
    [ :must_have_column, { name: 'lng', type: :float } ],
    [ :must_have_column, { name: 'provider', type: :string, limit: 16 } ],
    [ :must_have_column, { name: 'accuracy', type: :float } ],
    [ :must_have_column, { name: 'location_type', type: :string, limit: 32 } ],
    [ :must_have_column, { name: 'region', type: :string, limit: 128 } ],
  ]

  define_default_log_controller(self)

  geocoded_by :full_address, latitude: :lat, longitude: :lng

  reverse_geocoded_by :lat, :lng do |obj,results|
    obj.do_reverse_geocode(results)
  end

  def label
    full_address
  end

  def summary
    full_address
  end

  def full_address
    [street_address, city, state, country_code].compact.join(', ')
  end

  #
  # given an address string returns a new Location for that address
  #
  def self.new_for(address)
    obj = new(raw_address: address)

    geores = Geocoder.search(address)

    raise 'nil geocode result' if !geores

    obj.do_reverse_geocode(geores)

    obj
  end

  def do_reverse_geocode(results)
    geo = results.first

    return if !geo

    self.provider = geo.class.name.split('::').last.upcase
    self.raw_data = geo.data

    (self.lat, self.lng) = geo.coordinates
    self.city = geo.city
    self.province = geo.county
    self.state = geo.country
    self.country_code = geo.country_code
    self.zip = geo.postal_code
    self.street_address = geo.address
    self.location_type = geo.place_class

    self.accuracy = Geocoder::Calculations.distance_between(
     [ geo.boundingbox[2], geo.boundingbox[0] ],
     [ geo.boundingbox[3], geo.boundingbox[1] ]
    )
  end

end

end
end
