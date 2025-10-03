#
# Copyright (C) 2016-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Acao

class Aircraft::RestController < Ygg::Hel::RestController
  ar_controller_for Ygg::Acao::Aircraft

  view :grid do
    empty!
    attribute(:id) { show! }
    attribute(:uuid) { show! }
    attribute(:registration) { show! }
    attribute(:race_registration) { show! }
    attribute(:flarm_identifier) { show! }
    attribute(:icao_identifier) { show! }

    attribute(:aircraft_type) do
      show!
      empty!
      attribute(:name) { show! }
    end

    attribute(:club) do
      show!
      empty!
      attribute(:name) { show! }
    end

    attribute(:club_owner) do
      show!
      empty!
      attribute(:name) { show! }
    end

    attribute(:pilot) do
      show!
    end
  end

  view :edit do
    attribute(:aircraft_type) do
      show!
    end

    attribute :pilot do
      show!
    end

    attribute(:club) do
      show!
    end

    attribute(:club_owner) do
      show!
      empty!
      attribute(:name) { show! }
    end
  end

  load_role_defs!

  def by_code
    if match = /([a-z]+):(.*)/.match(params[:id])
      case match[1].upcase
      when 'FLARM'
        ar_resource = Ygg::Acao::Aircraft.find_by_flarm_identifier(match[2].upcase)
      when 'ICAO'
        ar_resource = Ygg::Acao::Aircraft.find_by_icao_identifier(match[2].upcase)
      else
        raise "Identifier type '#{match[1]}' not supported"
      end

      if ar_resource
        expires_in 1.hour, public: true
        ar_respond_with(ar_resource)
      else
        ar_respond_with({}, status: 404)
      end
    else
      ar_respond_with({}, status: 404)
    end
  end

  def authorization_prefilter
    # FIXME, use owners join table
    ar_model.where(owner_id: aaa_context.auth_person.id)
  end

  build_member_roles(:blahblah) do |obj|
    aaa_context &&
    aaa_context.authenticated? &&
    aaa_context.auth_person.id == obj.owner_id ? [ :owner ] : []
    # FIXME, use owners join table
  end

  def upload_photo
    ensure_authenticated!

    File.open(File.join(Rails.application.config.acao.pics_store, "#{params[:id]}_ac_photo"), 'w') do |file|
      IO.copy_stream(request.body, file)
    end

    # require 'rszr'
    # image = Rszr::Image.load('/opt/pics/b57b0da8-6156-495c-8a01-2f66d5ceb230_ac_photo')
    # image.resize!(64,64)
    # image.save('/opt/pics/b57b0da8-6156-495c-8a01-2f66d5ceb230_ac_photo-64x64')
  end
end

end
end
