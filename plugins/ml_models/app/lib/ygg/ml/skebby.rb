#
# Copyright (C) 2017-2018, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'uri'
require 'am/http/client'

module Ygg
module Ml

module Skebby
  class SkebbyError < StandardError
    attr_accessor :text

    def initialize(**args)
      super

      args.each { |k,v| send("#{k}=", v) }
    end
  end

  class NotAuthorized < SkebbyError
  end

  def self.http(debug: 0)
    @http ||= AM::HTTP::Client.new(debug: debug)
  end

  def self.get_token(username:, password:)

    uri = URI('https://api.skebby.it/API/v1.0/REST/token')
    uri.query = { username: username, password: password }.map { |k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v)}" }.join('&')

    res = http.get(uri,
      headers: {
        'User-Agent': 'Yggdra/2.0',
        'Accept': 'application/json',
        'X-Girls-Cups-Ratio': '2',
      }
    )

    (user_key, auth_token) = res.body.split(';')

    {
     user_key: user_key,
     auth_token: auth_token,
    }
  end

  def self.check_token(sender:)
    raise ArgumentError, 'Sender has empty username' if !sender.skebby_username || sender.skebby_username.empty?
    raise ArgumentError, 'Sender has empty password' if !sender.skebby_password || sender.skebby_password.empty?

    if !sender.skebby_user_key || !sender.skebby_token
      auth_token = get_token(username: sender.skebby_username, password: sender.skebby_password)

      sender.skebby_user_key = auth_token[:user_key]
      sender.skebby_token = auth_token[:auth_token]
      sender.save!
    end
  end

  def self.send_sms(sender:, **args)
    if sender
      check_token(sender: sender)
      user_key = sender.skebby_user_key
      token = sender.skebby_token
    elsif !user_key || !token
      raise ArgumentError, "user_key/token or sender must be specified"
    end

    send_sms_raw(user_key: user_key, token: token, **args)
  end

  def self.send_sms_raw(
        user_key: nil,
        token: nil,
        message_type: 'GP',
        recipients:,
        text:,
        order_id: nil,
        sms_sender: nil,
        scheduled_delivery_time: nil,
        debug: 0)

    recipients = [ recipients ] unless recipients.is_a?(Array)

    body = {
      message_type: message_type,
      message: text,
      recipient: recipients,
      encoding: 'gsm',
      returnCredits: false,
    }

    body[:sms_sender] = sms_sender if sms_sender
    body[:scheduled_delivery_time] = scheduled_delivery_time.strftime('%Y-%m-%d %H:%M') if scheduled_delivery_time
    body[:order_id] = order_id if order_id

    response = http.post('https://api.skebby.it/API/v1.0/REST/sms',
      headers: {
        'User-Agent': 'Yggdra/2.0',
        'X-Girls-Cups-Ratio': '2',
        'user_key': user_key,
        'Access_token': token,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: body.to_json,
    )

    response_body = JSON.parse(response.body).with_indifferent_access
    response_body
  end

  def self.get_sms_state(sender:, **args)
    if sender
      check_token(sender: sender)
      user_key = sender.skebby_user_key
      token = sender.skebby_token
    elsif !user_key || !token
      raise ArgumentError, "user_key/token or sender must be specified"
    end

    get_sms_state_raw(user_key: user_key, token: token, **args)
  end

  class OrderNotFound < SkebbyError
  end

  def self.get_sms_state_raw(order_id:, user_key:, token:)

    response = http.get("https://api.skebby.it/API/v1.0/REST/sms/#{order_id.to_s}",
      headers: {
        'User-Agent': 'Yggdra/2.0',
        'X-Girls-Cups-Ratio': '2',
        'user_key': user_key,
        'Access_token': token,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    )

    case response.status_code
    when 200
    when 401
      raise NotAuthorized.new(text: response.reason_phrase)
    when 404
      raise OrderNotFound.new(text: response.reason_phrase)
    else
      raise SkebbyError.new(text: response.reason_phrase)
    end

    response_body = JSON.parse(response.body).with_indifferent_access
    response_body
  end
end

end
end
