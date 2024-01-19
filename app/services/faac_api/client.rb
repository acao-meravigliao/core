#
# Copyright (C) 2017-2017, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module FaacApi

class Client
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
    res = @http.get('/keydom/api-external/users/internal/getPage',
      query: { pageIndex: page_index, pageSize: page_size },
      headers: { 'Accept': 'application/json', 'fio-access-token': @token }
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
    rate_limit

    res = @http.post('/keydom/api-external/users/internal/insert',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'fio-access-token': @token,
      },
      body: data.to_json
    )
  end

  def user_update(data:)
    rate_limit

    res = @http.put('/keydom/api-external/users/internal/update',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'fio-access-token': @token,
      },
      body: data.to_json
    )
  end

  def user_delete(uuid:)
    rate_limit

    res = @http.put('/keydom/api-external/users/internal/delete',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'fio-access-token': @token,
      },
      query: {
        uuid: uuid,
      },
    )
  end


  def media_get(page_index: 0, page_size: 1000)
    res = @http.get('/keydom/api-external/accessMedias/getPage',
      query: { pageIndex: page_index, pageSize: page_size },
      headers: { 'Accept': 'application/json', 'fio-access-token': @token }
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
    rate_limit

    res = @http.post('/keydom/api-external/accessMedias/insert',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'fio-access-token': @token,
      },
      body: data.to_json
    )
  end

  def media_update(data:)
    rate_limit

    res = @http.put('/keydom/api-external/accessMedias/update',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'fio-access-token': @token,
      },
      body: data.to_json
    )
  end

  def media_remove(uuid:)
    rate_limit

    res = @http.delete('/keydom/api-external/accessMedias/delete',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'fio-access-token': @token,
      },
      query: {
        uuid: uuid,
      },
    )
  end

  def media_remove_range(from_number:, to_number:)
    rate_limit

    res = @http.delete('/keydom/api-external/accessMedias/deleteBy',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'fio-access-token': @token,
      },
      body: {
        startNumber: from_number,
        endNumber: to_number,
      },
    )
  end

  def action_get_all
    rate_limit

    res = @http.get('/keydom/api-external/actions/getAll',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'fio-access-token': @token,
      },
    )

    res
  end

  def action_perform(uuid:)
    rate_limit

    res = @http.put('/keydom/api-external/actions/perform',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'fio-access-token': @token,
      },
      query: {
        uuid: uuid,
      }
    )
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

    @last_req_ts = Time.now
  end
end

end
