#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module FaacApi

class Client
  attr_reader :http
  attr_reader :token

  def initialize(endpoint: Rails.application.config.acao.faac_endpoint, debug: Rails.application.config.acao.faac_debug)
    @http = AM::HTTP::BasicClient.new(
      base_uri: endpoint,
      tls_params: {
        verify_mode: OpenSSL::SSL::VERIFY_NONE,
        verify_hostname: false
      },
      debug: debug
    )
  end

  def login(username: Rails.application.config.acao.faac_generic_user, password: Rails.application.secrets.faac_generic_user_password)
    res = @http.post('keydom/api-external/authentication/login',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      },
      body: {
        username: username,
        passwordHash: Digest::MD5.hexdigest(password).upcase
      }.to_json
    )

    body = JSON.parse(res.body, symbolize_names: true)
    @token = body[:data][:token]

    @token
  end

  def users_get(page_index: 0, page_size: 1000)
    res = genreq(verb: 'GET', uri: '/keydom/api-external/users/internal/getPage',
      query: { pageIndex: page_index, pageSize: page_size },
    )

    body = JSON.parse(res.body, symbolize_names: true)

    body[:data]
  end

  def users_get_all
    page = 0
    users = []

    loop do
      res = users_get(page_index: page, page_size: 1000)

      if res.count > 1000
        raise "FAAC API has changed, code needs update, res.count == #{res.count}"
      end

      users += res

      if res.count < 1000
        break
      end

      page += 1
    end

    users
  end

  def user_create(data:)
    res = genreq(verb: 'POST', uri: '/keydom/api-external/users/internal/insert',
      body: data.to_json
    )
  end

  def user_update(data:)
    genreq(verb: 'PUT', uri: '/keydom/api-external/users/internal/update',
      body: data.to_json
    )
  end

  def user_remove(uuid:)
    genreq(verb: 'DELETE', uri: '/keydom/api-external/users/delete',
      query: {
        uuid: uuid,
      },
    )
  end


  def media_get(page_index: 0, page_size: 1000)
    res = genreq(verb: 'GET', uri: '/keydom/api-external/accessMedias/getPage',
      query: { pageIndex: page_index, pageSize: page_size },
    )

    body = JSON.parse(res.body, symbolize_names: true)

    body[:data]
  end

  def medias_get_all
    page = 0
    users = []

    loop do
      res = media_get(page_index: page, page_size: 1000)

      if res.count > 999
        raise "FAAC API has changed, code needs update"
      end

      users += res

      if res.count < 999
        break
      end

      page += 1
    end

    users
  end

  def media_create(data:)
    genreq(verb: 'POST', uri: '/keydom/api-external/accessMedias/insert',
      body: data.to_json
    )
  end

  def media_update(data:)
    genreq(verb: 'pout', uri: '/keydom/api-external/accessMedias/update',
      body: data.to_json
    )
  end

  def media_remove(uuid:)
    genreq(verb: 'DELETE', uri: '/keydom/api-external/accessMedias/delete',
      query: {
        uuid: uuid,
      },
    )
  end

  def media_remove_range(from_number:, to_number:)
    genreq(verb: 'DELETE', uri: '/keydom/api-external/accessMedias/deleteBy',
      body: {
        startNumber: from_number,
        endNumber: to_number,
      },
    )
  end

  def action_get_all
    genreq(verb: 'GET', uri: '/keydom/api-external/actions/getAll')
  end

  def action_perform(uuid:)
    genreq(verb: 'PUT', uri: '/keydom/api-external/actions/perform',
      query: {
        uuid: uuid,
      }
    )
  end

  def genreq(verb:, uri:, headers: {}, query: {}, body: nil)
    headers = {
      'Accept': 'application/json',
      'fio-access-token': @token,
    }.merge(headers)

    # Workaround for buggy server
    if verb != 'GET'
      headers[:'Content-Type'] = 'application/json; charset=utf-8'
    end

    rate_limit do
      @http.request(uri, verb: verb,
        headers: headers,
        query: query,
        body: body,
      )
    end
  end

  def rate_limit
    # WTF, there is a rate limit that make requests FAIL if sent within 100 ms
    # "It has to pass 100 milliseconds between each call to this endpoint method"

    if @last_req_ts
      diff = Time.now - @last_req_ts
      if diff < 0.1
        sleep(0.1 - diff)
      end
    end

    res = yield

    @last_req_ts = Time.now

    res
  end
end

end
