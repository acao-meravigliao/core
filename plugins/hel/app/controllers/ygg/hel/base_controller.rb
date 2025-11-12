#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#
# Hel's BaseController includes common functionalities for all Hel's controller. It does retrieve session information if
# present and provide common methods to check session validity.
#

require 'json'

module Ygg
module Hel

class BaseController < ActionController::Base

  layout false

  class AAAContextInvalid < RailsActiveRest::Controller::AAAError
    def initialize(**args)
      super(
        http_status_code: 401,
        headers: { 'WWW-Authenticate' => "Bearer error=\"aaa_context_invalid\", error_description=\"AAA Context Invalid\"" },
        **args)
    end
  end

  class AAASessionIdInvalid < RailsActiveRest::Controller::AAAError
    def initialize(**args)
      super(
        http_status_code: 401,
        headers: { 'WWW-Authenticate' => "Bearer error=\"invalid_session_id\", error_description=\"Session ID is invalid\"" },
        **args)
    end
  end

  class AAAContextNotFoundError < RailsActiveRest::Controller::AAAError
    def initialize(**args)
      super(
        http_status_code: 401,
        headers: { 'WWW-Authenticate' => "Bearer error=\"missing_session\", " +
                                         "error_description=\"Session identifier not provided or session not found\"" },
        **args)
    end
  end

  include RailsActiveRest::Controller::Rescuer
  include Ygg::Core::RoleDefsLoader

  rescue_from RailsActiveRest::Controller::Error do |e|
    ar_exception_rescue_action(e, log_level: :none)
  end

  protected

  def hel_transaction(msg, request_id: request.uuid, **args, &block)
    Ygg::Core::Transaction.new(msg, aaa_context: aaa_context, request_id: request_id, **args, &block)
  end

  def json_request
    return @json_request if @json_requestA

    @json_request = JSON.parse(request.body.read, symbolize_names: true)
    @json_request
  end

  def find_session(id)
    if (id =~ /^[\da-z]{8}-[\da-z]{4}-[\da-z]{4}-[\da-z]{4}-[\da-z]{12}$/i)
      sess = Ygg::Core::Session.find_by(id: id)
      raise AAAContextNotFoundError if !sess
      sess
#    elsif matches oauth token?
#      lookup oauth token
    else
      raise AAASessionIdInvalid
    end

    sess
  end

  attr_accessor :aaa_context

  def retrieve_aaa_context_from_headers
    sess = nil

    auth_hdr = request.headers['Authorization']
    if auth_hdr && auth_hdr =~ /^Bearer (.*)$/i
      sess = find_session($1)
    end

    sess = find_session(request.headers['Session-Id']) if request.headers['Session-Id']
    sess = find_session(request.cookies['Session-Id']) if request.cookies['Session-Id']

    ::I18n.locale = (sess && (sess.language &&
                              sess.language.iso_639_1 ||
                              sess.auth_person &&
                              sess.auth_person.preferred_language &&
                              sess.auth_person.preferred_language.iso_639_1)) || :it

    sess
  end

  def retrieve_aaa_context!
    @aaa_context = retrieve_aaa_context_from_headers
  end

  def retrieve_client_certificate
    request.env['SSL_CLIENT_CERT']
  end

  class AAAContextInvalid::NotAuthenticated < AAAContextInvalid ; end
  class AAAContextInvalid::SessionClosed < AAAContextInvalid ; end
  class AAAContextInvalid::SessionStatusInvalid < AAAContextInvalid ; end

  def ensure_authenticated!
    retrieve_aaa_context!

    if !aaa_context
      raise AAAContextNotFoundError
    elsif !aaa_context.authenticated?
      case aaa_context.status
      when :new
        raise AAAContextInvalid::NotAuthenticated
      when :closed
        raise AAAContextInvalid::SessionClosed
      else
        raise AAAContextInvalid::SessionStatusInvalid
      end
    end

    true
  end

  # Ensures the current session is authenticated. Should be overridden by child controllers if they want to add other
  # authorization steps
  #
  def ensure_authenticated_and_authorized!
    ensure_authenticated!
    true
  end

  def is_param_true?(val)
    val && !([ 'f', 'false', '0', 'n', '' ].include?(val.downcase))
  end

end

end
end
