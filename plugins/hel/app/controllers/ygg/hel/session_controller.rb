#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Hel

# Session handling controller
#
# This controller handles session lifecycle, from creation to authentication to closure.
#
# To use client certificates the HTTP server must be configured to provide the full certificate in the request's
# enviroment, in the SSL_CLIENT_CERT variable.
#
# With Apache it can be accompished by setting the ExportCertData variable in SSLOptions, e.g.:
#
# SSLOptions +StdEnvVars +ExportCertData
#
# Most action return a session object with the following attributes:
#
# [:id]                   The session-id in UUID format
# [:authenticated]        boolean value to indicate an authenticated session
# [:status]               Symbolic status, current values are :new, :authenticated, :closed
# [:started_at]           Session's start time
# [:auth_credential]      Credential type used to authenticate the session
# [:auth_person]          Person used to authenticate the session
# [:auth_method]          Authentication method used
#                         [:client_cert_dn]    Client certificate
#                         [:fqda_and_password] FQDA and password
# [:auth_confidence]      Authentication confidence
#
class SessionController < Ygg::Hel::BaseController

  include RailsActiveRest::Controller::Responder

  # Obtain informations on an existing session.
  #
  # This action obtains the session-id from the POST request body or, if not specified (or a GET) from the existing session
  # The existing session is retrieved from BaseController.
  #
  # If the session is specified in the POST request and it is not found a session object { id: nil, reason: :not_found } is
  # returned, otherwise BaseController behaviour prevails (an exception is raised leading to 401 response)
  #
  # The reply contains the session object in the requested format.
  #
  def check
    if request.method == 'POST' && json_request[:session_id]
      sess = find_session(json_request[:session_id])
      respond_with_session(sess)
    else
      respond_with_session(retrieve_aaa_context_from_headers)
    end
  rescue AAASessionIdInvalid
    respond_with_session(nil, reason: :session_id_invalid)
  rescue AAAContextNotFoundError
    respond_with_session(nil, reason: :not_found)
  end

  # Obtain informations on an existing session.
  #
  # This action obtains the session-id from the POST request body or creates a new session
  # A valid session is guaranteed to be returned and gets created if not existant.
  #
  # The reply contains the session object in the requested format.
  #
  def check_or_create
    begin
      aaa_context ||= retrieve_aaa_context_from_body(json_request)
      aaa_context ||= retrieve_aaa_context_from_headers
    rescue AAAContextNotFoundError
    rescue AAASessionIdInvalid
    end

    if request.method == 'POST' && (!aaa_context || !aaa_context.active?)
      aaa_context = create_session_from_http_connection
      aaa_context.save!
    end

    # Uh??
    response.set_cookie('Language', request.cookies['Language'])

    respond_with_session(aaa_context)
  end

  # Forcibly allocate a new session and return it both as an object and a X-Ygg-Session-Id header
  #
  # Should be only invoked via POST verb as has side effects
  #
  def create
    aaa_context = create_session_from_http_connection
    aaa_context.save!

    respond_with_session(aaa_context)
  end

  # Responds with an authentication token if the user would authenticate using a fqda/password pair
  #
  # If the session-id is not given in a X-Ygg-Session-Id header, a new session is created at the same time.
  # The specified or newly created session's id is included in the reply's header X-Ygg-Session-Id.
  #
  # The accepted parameters are:
  # [:fqda]           FQDA (fully qualified domain address).
  # [:username]       FQDA (fully qualified domain address), accepted when [:fqda] is not specified as a way to
  #                   support browsers' password managers.
  # [:password]       The cleartext password.
  #
  # The reply contains the authentication token
  #
  def would_authenticate_by_fqda_and_password
    msg = ''
    reason = ''
    authenticated = false

    begin
      auth_token = Ygg::Core::Authenticator.by_fqda_and_password(
                                  fqda: json_request[:fqda], password: json_request[:password])
    rescue Ygg::Core::Authenticator::FQDAFormat => e
      msg = e.message
      reason = :fqda_format_invalid
    rescue Ygg::Core::Authenticator::FQDANotFound, Ygg::Core::Authenticator::WrongCredentials
      msg = 'Wrong credentials'
      reason = :invalid_credentials
      sleep 2
    else
      msg = 'Auhtentication successful!'
      reason = :ok
      authenticated = true
    end

    response = {
      msg: msg,
      reason: reason,
      authenticated: authenticated,
    }

    respond_to do |format|
      format.json { render json: response }
      format.xml { render xml: response }
      format.yaml { render yaml: response }
    end
  end

  # Attempts to authenticate a session by using a fqda/password pair
  #
  # If the session-id is not given either in request body, Authenticate header or cookie, a new session is created
  # at the same time.
  # The specified or newly created session's id is included in the reply's header X-Ygg-Session-Id.
  #
  # The accepted parameters are:
  # [:session_id]     Session ID (if not present it will be taken from headers or cookie)
  # [:fqda]           FQDA (fully qualified domain address).
  # [:username]       FQDA (fully qualified domain address), accepted when [:fqda] is not specified as a way to
  #                   support browsers' password managers.
  # [:password]       The cleartext password.
  # [:associate_cert] If a X.509 client-certificate is presented in the request, it is associated with the
  #                   identity on success.
  #
  # The reply contains the session object.
  # In addition to the session's usual attributes two attributes are included to describe the authentication result:
  # [:msg]            Human-readable explanation of the result
  # [:reason]         Can be either :ok or :wrong_credentials
  #
  def authenticate_by_fqda_and_password
    msg = ''
    reason = ''
    aaa_context = nil

    ActiveRecord::Base.transaction do
      begin
        aaa_context ||= retrieve_aaa_context_from_body(json_request)
        aaa_context ||= retrieve_aaa_context_from_headers
      rescue AAAContextNotFoundError
      end

      if !aaa_context
        aaa_context = create_session_from_http_connection
        aaa_context.save!
      end

      aaa_context.language = Ygg::I18n::Language.find_by!(iso_639_1: json_request.fetch(:language, 'en'))
      aaa_context.save

      begin
        auth_token = Ygg::Core::Authenticator.by_fqda_and_password(fqda: json_request[:fqda], password: json_request[:password])
      rescue Ygg::Core::Authenticator::FQDAFormat => e
        msg = e.message
        reason = :fqda_format_invalid
      rescue Ygg::Core::Authenticator::FQDANotFound, Ygg::Core::Authenticator::WrongCredentials
        msg = 'Wrong credentials'
        reason = :invalid_credentials
        sleep 2
      else
        aaa_context.authenticated!(auth_token)
        aaa_context.expires = json_request[:keep_connected] ? nil : Time.now + 10.minutes

        lang_code = json_request[:language]
        if lang_code
          aaa_context.set_language(lang_code)
        end

        aaa_context.save!

        if json_request[:associate_cert] && retrieve_client_certificate
          cert = OpenSSL::X509::Certificate.new(retrieve_client_certificate)
          ccred = Ygg::Core::Person::Credential::X509Certificate.new
          ccred.cert = cert
          ccred.descr = cert.subject.to_a[0][1]
          ccred.identity = auth_token.identity
          ccred.save!
        end

        if cookies['X-Sevio-Realm'] && (realm = aaa_context.auth_person.sev_realms.find_by(id: cookies['X-Sevio-Realm']))
          aaa_context.sev_realm = realm
        end

        msg = 'Auhtentication successful!'
        reason = :ok
      end
    end

    respond_with_session(aaa_context, msg: msg, reason: reason)
  end

  def authenticate_by_keyfob
    msg = ''
    reason = ''
    aaa_context = nil

    ActiveRecord::Base.transaction do
      begin
        aaa_context ||= retrieve_aaa_context_from_body(json_request)
        aaa_context ||= retrieve_aaa_context_from_headers
      rescue AAAContextNotFoundError
      end

      if !aaa_context
        aaa_context = create_session_from_http_connection
        aaa_context.save!
      end

      aaa_context.language = Ygg::I18n::Language.find_by!(iso_639_1: json_request.fetch(:language, 'en'))
      aaa_context.save

      begin
        auth_token = Ygg::Core::Authenticator.by_keyfob(keyfob_id: json_request[:keyfob_id])
      rescue Ygg::Core::Authenticator::FQDAFormat => e
        msg = e.message
        reason = :fqda_format_invalid
      rescue Ygg::Core::Authenticator::FQDANotFound, Ygg::Core::Authenticator::WrongCredentials
        msg = 'Wrong credentials'
        reason = :invalid_credentials
        sleep 2
      else
        aaa_context.authenticated!(auth_token)
        aaa_context.expires = json_request[:keep_connected] ? nil : Time.now + 10.minutes

        lang_code = json_request[:language]
        if lang_code
          aaa_context.set_language(lang_code)
        end

        aaa_context.save!

        if json_request[:associate_cert] && retrieve_client_certificate
          cert = OpenSSL::X509::Certificate.new(retrieve_client_certificate)
          ccred = Ygg::Core::Person::Credential::X509Certificate.new
          ccred.cert = cert
          ccred.descr = cert.subject.to_a[0][1]
          ccred.identity = auth_token.identity
          ccred.save!
        end

        if cookies['X-Sevio-Realm'] && (realm = aaa_context.auth_person.sev_realms.find_by(id: cookies['X-Sevio-Realm']))
          aaa_context.sev_realm = realm
        end

        msg = 'Auhtentication successful!'
        reason = :ok
      end
    end

    respond_with_session(aaa_context, msg: msg, reason: reason)
  end

  # Attemps to authenticate a session by using the X.509 client certificate sent in the HTTP request
  #
  # The session object is returned in the reply
  #
  def authenticate_by_certificate

    aaa_context = retrieve_aaa_context_from_headers

    body = request.body.read

    if request.media_type == 'application/x-x509-user-cert' && !body.empty?
      cert = OpenSSL::X509::Certificate.new(body)
    elsif retrieve_client_certificate
      cert = OpenSSL::X509::Certificate.new(retrieve_client_certificate)
    else
      respond_with_session(aaa_context, reason: :no_certificate_found)
      return
    end

    auth_token = Ygg::Core::Authenticator.by_cert(cert: cert)

    aaa_context.authenticated!(auth_token)

    respond_with_session(aaa_context)
  end

  # Attempts to authenticate a session by using a fqda/password pair for a third party.
  #
  # Session ID is accepted in the request body only, along with HTTP environment data.
  #
  # The accepted parameters are:
  # [:fqda]             FQDA (fully qualified domain address).
  # [:password]         The cleartext password.
  # [:other_fqda]       FQDA of other person
  #
  # [:remote_addr]      HTTP parameters
  # [:remote_port]
  # [:x_forwarded_for]
  # [:via]
  # [:server_addr]
  # [:server_port]
  # [:server_name]
  # [:referer]
  # [:user_agent]
  # [:request_uri]
  #
  # The reply contains the session object.
  # In addition to the session's usual attributes two attributes are included to describe the authentication result:
  #
  # [:msg]            Human-readable explanation of the result
  # [:reason]         Can be either :ok or :wrong_credentials
  #
  def proxy_authenticate_by_fqda_and_password
    msg = ''
    reason = ''
    aaa_context = nil

    ActiveRecord::Base.transaction do
      begin
        aaa_context ||= retrieve_aaa_context_from_body(json_request)
        aaa_context ||= retrieve_aaa_context_from_headers
      rescue AAAContextNotFoundError
      end

      if !aaa_context
        aaa_context = create_session_from_http_connection
        aaa_context.save!
      end

      begin
        auth_token = Ygg::Core::Authenticator.proxy_by_fqda_and_password(
                       fqda: json_request[:fqda], password: json_request[:password],
                       other_fqda: json_request[:other_fqda])
      rescue Ygg::Core::Authenticator::FQDAFormat => e
        msg = e.message
        reason = :fqda_format_invalid
      rescue Ygg::Core::Authenticator::FQDANotFound, Ygg::Core::Authenticator::WrongCredentials
        msg = 'Wrong credentials'
        reason = :invalid_credentials
        sleep 2
      rescue Ygg::Core::Authenticator::ProxyNotAuthorized
        msg = "Proxy Authentication Not Authorized"
        reason = :proxy_authentication_not_authorized
      rescue Ygg::Core::Authenticator::ProxyOtherFQDANotFound
        msg = "Other FQDA not found"
        reason = :proxy_other_fqda_not_found
      else
        aaa_context.authenticated!(auth_token)

        lang_code = json_request[:language]
        if lang_code
          aaa_context.set_language(lang_code)
        end

        aaa_context.save!

        msg = 'Auhtentication successful!'
        reason = :ok
      end
    end

    respond_with_session(aaa_context, msg: msg, reason: reason)
  end


  # Attemps to authenticate a session by using the X.509 client certificate sent by a trusted party
  #
  # The accepted parameters are:
  # [:session_id]       Session ID for the operation
  # [:other_session_id] Session ID being authenticated
  # [:fqda]             FQDA (fully qualified domain address).
  #
  # [:remote_addr]      HTTP parameters
  # [:remote_port]
  # [:x_forwarded_for]
  # [:via]
  # [:server_addr]
  # [:server_port]
  # [:server_name]
  # [:referer]
  # [:user_agent]
  # [:request_uri]
  #
  # The reply contains the session object.
  # In addition to the session's usual attributes two attributes are included to describe the authentication result:
  #
  # [:msg]            Human-readable explanation of the result
  # [:reason]         Can be either :ok or :wrong_credentials
  #
  def proxy_authenticate_by_certificate
    # Temporary until Extgui could open his session and authenticate
    if request.env['REMOTE_ADDR'] != '' &&
       request.env['REMOTE_ADDR'] != '::1' &&
       request.env['REMOTE_ADDR'] != '127.0.0.1'
      aaa_context ||= retrieve_aaa_context_from_body(json_request)
      aaa_context ||= retrieve_aaa_context_from_headers

      if !aaa_context.has_global_roles?(:proxy_authenticate)
        raise RailsActiveRest::Controller::AuthorizationError.new(
                title: 'You do not have the required role',
                title_sym: 'you_do_not_have_the_required_role')
      end
    end

    lang = Ygg::I18n::Language.find_by(iso_639_1: json_request[:language]) ||
           Ygg::I18n::Language.find_by(iso_639_1: 'en') ||
           Ygg::I18n::Language.first

    raise 'No language available' if !lang

    sess = find_session(json_request[:other_session_id]) if json_request[:other_session_id]
    sess ||= Ygg::Core::Session.create(
               language: lang,
               http_server_addr: json_request[:server_addr],
               http_server_port: json_request[:server_port],
               http_server_name: json_request[:server_name],
               http_remote_addr: json_request[:remote_addr],
               http_remote_port: json_request[:remote_port],
               http_x_forwarded_for: json_request[:x_forwarded_for],
               http_via: json_request[:via],
               http_referer: json_request[:referer],
               http_user_agent: json_request[:user_agent],
               http_request_uri: json_request[:request_uri],
             )

    cert = OpenSSL::X509::Certificate.new(json_request[:certificate])

    auth_token = attempt_authentication_by_cert(cert)

    if auth_token
      sess.authenticated!(auth_token)
    end

    respond_with_session(sess)
  end

  def refresh
    aaa_context = retrieve_aaa_context_from_headers

    # TODO: check that it is not expired already

    if aaa_context && aaa_context.expires
      aaa_context.expires = Time.now + 10.minutes
    end

    respond_with_session(aaa_context)
  end

  # Renew a stale session
  #
  # Currently broken: To be fixed/documented
  #
  def renew
    aaa_context = retrieve_aaa_context_from_headers

    auth_token = attempt_authentication(form: { fqda: json_request[:fqda],
                                                   password: jston_request[:password]})

    if auth_token
    else
    end

    respond_with_session(aaa_context)
  end

  # Close the session.
  #
  # A closed session may not be opened anymore
  #
  def logout
    aaa_context = retrieve_aaa_context_from_headers

    aaa_context.close!(:hel_logout) if aaa_context.active?

    respond_with_session(aaa_context)
  rescue AAASessionIdInvalid
    respond_with_session(nil, reason: :session_id_invalid)
  rescue AAAContextNotFoundError
    respond_with_session(nil, reason: :not_found)
  end

  def api_login
  end

  private

  def user_preferred_languages(header)
    languages = {}

    begin
      header.to_s.gsub(/\s+/, '').split(',').map do |language|
        locale, quality = language.split(';q=')
        raise ArgumentError, 'Not correctly formatted' unless locale =~ /^[a-z\-0-9]+|\*$/i

        locale  = locale.downcase.gsub(/-[a-z0-9]+$/i, &:upcase) # Uppercase territory
        locale  = nil if locale == '*' # Ignore wildcards

        quality = quality ? quality.to_f : 1.0

        languages[locale] = quality
      end
    rescue ArgumentError # Just rescue anything if the browser messed up badly.
    end

    languages
  end

  def create_session_from_http_connection
    if cookies['Language']
      lang = Ygg::I18n::Language.find_by(iso_639_1: cookies['Language'])
    else
      pref_langs = user_preferred_languages(request.headers['Accept-Language'])

      lang = nil
      pref_langs.sort_by { |k,v| v }.reverse.detect { |k,v| lang = Ygg::I18n::Language.find_by(iso_639_1: k.to_s) }
    end

    lang ||= Ygg::I18n::Language.find_by(iso_639_1: 'en') || Ygg::I18n::Language.first

    raise 'No language available' if !lang

    env = {
      http_remote_addr: request.env['REMOTE_ADDR'],
      http_remote_port: request.env['REMOTE_PORT'],

      http_x_forwarded_for: request.env['HTTP_X_FORWARDED_FOR'],
      http_via: request.env['HTTP_VIA'],

      http_server_addr: request.env['SERVER_ADDR'],
      http_server_port: request.env['SERVER_PORT'],
      http_server_name: request.env['HTTP_HOST'],

      http_referer: request.env['HTTP_REFERER'],
      http_user_agent: request.env['HTTP_USER_AGENT'],
      http_request_uri: request.env['REQUEST_URI'],

      language: lang,
    }

    Ygg::Core::Session.create!(env)
  end

  protected

  # Try to fetch session from session_id attribute in JSON encoded body
  #
  # This may be called before accessing #aaa_context to prevent loading session from header/cookie or to override it.
  #
  def retrieve_aaa_context_from_body(req)
    find_session(req[:session_id]) if req[:session_id]
  end

  def respond_with_session(session, opts = {})

    response = { id: nil }

    if session
      response.merge!({
        id: session.id,
        authenticated: session.authenticated?,
        status: session.status,
        started_at: session.created_at,
        language: session.language.iso_639_1,
        expires: session.expires,
      })

      if session.authenticated?
        response.merge!({
          auth_method: session.auth_method,
          auth_person: {
            id: session.auth_person.id,
            name: session.auth_person.name,
            preferred_language: session.auth_person.preferred_language.try(:iso_639_1),
          },
          auth_confidence: session.auth_confidence,
          roles: session.auth_person.roles.map(&:name),
        })

        response.merge!({
          auth_credential: {
            type: session.auth_credential.class.to_s,
            id: session.auth_credential.id,
            fqda: session.auth_credential.fqda,
          },
        }) if session.auth_credential
      end
    end

    response.merge!({
      active: session ? session.active? : false,
      authenticated: session ? session.authenticated? : false,
    })

    response[:data] ||= {}
    response[:data].merge!(session.data) if session.respond_to?(:data)

    response.merge!(opts)

    if session
      headers['X-Ygg-Session-Id'] = session.id
      #cookies['Session-Id'] = { value: session.id, secure: true }
      cookies['Session-Id'] = { value: session.id, expires: session.expires }
      cookies['Language'] = session.language.iso_639_1
    end

    ar_respond_with(response)
  end

end
end

end
