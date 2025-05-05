## frozen_string_literal: true
##
## Copyright (C) 2017-2020, Daniele Orlandi
##
## Author:: Daniele Orlandi <daniele@orlandi.com>
##
## License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
##
#
###require 'am/session_manager'
#
##require 'am/vos/session'
#require 'am/ws/server_socket'
#
#require 'ygg/diffable'
#require 'iarray'
#
#module RailsVos
#
#class Server
#
#class Connection
#  include AM::Actor
#
#  class Request
#    attr_accessor :id
#    attr_accessor :original_msg
#    attr_accessor :call_message
#
#    def initialize(**args)
#      args.each { |k,v| send("#{k}=", v) }
#    end
#  end
#
#  class MsgDeliver < AM::Msg
#    attr_accessor :routing_key
#    attr_accessor :exchange
#    attr_accessor :headers
#    attr_accessor :payload
#  end
#
#  class Parameters
#    include Ygg::Diffable
#
#    d_attr_accessor :keepalive_time
#    d_attr_accessor :keepalive_timeout
#    d_attr_accessor :keepalive_method
#    d_attr_accessor :accept
#    d_attr_accessor :content_type
#  end
#
#  class RequestException < Ygg::Exception
#  end
#
#  class ModelNotFound < RequestException ; end
#  class ControllerNotFound < RequestException ; end
#  class MissingId < RequestException ; end
#  class MissingObjectData < RequestException ; end
#  class MissingObjectDataId < RequestException ; end
#  class BindingNotFound < RequestException ; end
#  class MissingExchange < RequestException ; end
#  class RouteNotConfigured < RequestException ; end
#  class AuthenticationRequired < RequestException ; end
#  class SubscriptionNotFound < RequestException ; end
#  class ResourceNotReadable < RequestException ; end
#  class ResourceNotFound < RequestException ; end
#  class ResourceNotWritable < RequestException ; end
#  class AttributeNotWritable < RequestException ; end
#  class AttributeNotFound < RequestException ; end
#  class ResourceNotValid < RequestException ; end
#
#  def initialize(server:, socket:, remote_endpoint_real:, instance_id:, welcome_extra_params:, headers:, session:, calls_to: nil, events_to: nil, **args)
#    @server = server
#    @ruby_sock = socket
#    @remote_endpoint_real = remote_endpoint_real
#    @instance_id = instance_id
#    @welcome_extra_params = welcome_extra_params
#    @headers = headers
#    @session = session
#    @calls_to = calls_to
#    @events_to = events_to
#
#    @sets = {}
#
#    super(**args)
#  end
#
#  def actor_boot
#    @online = true
#    @idle_state = :unknown
#
#    @ctr_cache = {}
#
#    @requests = IArray.new
#    @requests.add_index(:by_id, &:id)
#    @requests.add_index(:by_callmsg, &:call_message)
#
#    @pars = Parameters.new(
#      keepalive_time: 5,
#      keepalive_timeout: 10,
#      keepalive_method: :pong,
##      accept: 'application/vnd.api+json',
##      content_type: 'application/vnd.api+json',
#    )
#
#    @ws = AM::WS::ServerSocket.new(
#      socket: @ruby_sock,
#      headers: @headers,
#      protocol: 'vos.vihai.it',
#      auto_json: true,
#      actor: self,
#      debug: @debug,
#    )
#
#    @ws.on_ready = method(:ws_ready)
#    @ws.on_text_frame = method(:on_text_frame)
#    @ws.on_bin_frame = method(:on_bin_frame)
#    @ws.on_disconnected = method(:disconnected)
#
#    if @headers['Session-Id']
#      @session_id = @headers['Session-Id']
#    elsif @headers['Cookie']
#      cookies = Hash[@headers['Cookie'].split(';').map { |x| x.strip.split('=') }]
#      @session_id = cookies['Session-Id']
#    end
#
#    @ws.start
#
#    self.actor_name = "vos-#{remote_endpoint}"
#
#    debug1 { "VOS #{remote_endpoint}: Connection open" }
#  end
#
#  def remote_endpoint
#    @remote_endpoint_real || @ws.remote_endpoint
#  end
#
#  class SessionNotFound < AM::WS::Socket::LocalClosure
#    def initialize(**args)
#      super(code: 1000, title: 'Session not found', **args)
#    end
#  end
#
#  class ErrorGettingSession < AM::WS::Socket::LocalClosure
#    def initialize(**args)
#      super(code: 1000, title: 'Error getting session', **args)
#    end
#  end
#
#  def ws_ready
#    debug3 { __method__ }
#
##    create_persistent_selection(model: Ygg::Core::HttpSession, filter: { id: @session.id })
#
###    if @session_id
###      @session = nil
###
###      begin
###        @session = AM::VOS::Session.new(ds: @ds, auth_manager: @auth_manager, id: @session_id)
###      rescue AM::AuthManager::MsgSessionGetNotFound => e
###        log.warn "Session not found"
###
###        transmit_msg({
###          type: 'exception',
###          body: e.as_json_problem,
###        })
###
###        @ws.close(cause: SessionNotFound.new)
###
###        return
###      rescue AM::AuthManager::MsgSessionGetNotAvailable => e
###        log.warn "SESSION GET NOT AVAILABLE #{e}"
###
###        transmit_msg({
###          type: 'exception',
###          body: e.as_json_problem,
###        })
###
###        @ws.close(cause: ErrorGettingSession.new)
###
###        return
###      end
###    end
#
#    transmit_msg({
#      type: 'welcome',
#      instance_id: @instance_id,
#      session: @session && @session.as_json,
#      online: @online,
#      pars: @pars.as_hash,
#    }.merge!(@welcome_extra_params))
#
#    ws_keepalive_start
#  end
#
#  def actor_handle(msg)
#    case msg
###    when AM::DataStore::Store::MsgObjectNotification
###      return unless @ws.ready?
###
###      subtype = case msg
###      when AM::DataStore::Store::MsgObjectCreated ; 'obj_created'
###      when AM::DataStore::Store::MsgObjectUpdated ; 'obj_updated'
###      when AM::DataStore::Store::MsgObjectDestroyed ; 'obj_destroyed'
###      when AM::DataStore::Store::MsgObjectSelected ; 'obj_selected'
###      when AM::DataStore::Store::MsgObjectDeselected ; 'obj_deselected'
###      end
###
###      transmit_msg({
###        type: 'notify',
###        subtype: subtype,
###        selection_ids: msg.selection_ids,
###        body: {
###          object: msg.object.as_jsonapi,
###        },
###      })
###
###    when AM::DataStore::Store::MsgRelationNotification
###      return unless @ws.ready?
###
###      subtype = case msg
###      when AM::DataStore::Store::MsgRelationCreated ; 'rel_created'
###      when AM::DataStore::Store::MsgRelationDestroyed ; 'rel_destroyed'
###      when AM::DataStore::Store::MsgRelationSelected ; 'rel_selected'
###      when AM::DataStore::Store::MsgRelationDeselected ; 'rel_deselected'
###      end
###
###      transmit_msg({
###        type: 'notify',
###        subtype: subtype,
###        selection_ids: msg.selection_ids,
###        body: {
###          relation: msg.relation.as_json,
###        },
###      })
#
#    when MsgCallOk
#      return unless @ws.ready?
#
#      req = @requests.by_callmsg[msg.in_reply_to]
#      if !req
#        log.warn "Received MsgCallOk for unknown message"
#        return
#      end
#
#      transmit_req_ok(reply_to: req.original_msg, body: msg.body)
#
#    when MsgCallFail
#      return unless @ws.ready?
#
#      req = @requests.by_callmsg[msg.in_reply_to]
#      if !req
#        log.warn "Received MsgCallFail for unknown message"
#        return
#      end
#
#      if msg.cause
#        body = msg.cause.respond_to?(:as_json_problem) ? msg.cause.as_json_problem : Ygg::Exception.other_as_json_problem(msg.cause)
#      else
#        body = msg.as_json_problem
#      end
#
#      transmit_req_fail(reply_to: req.original_msg, body: body)
#
#    when MsgDeliver
#      transmit_msg({
#        type: 'delivery',
#        exchange: msg.exchange,
#        headers: msg.headers,
#        body: msg.payload,
#      })
#
#    else
#      super
#    end
#  end
#
#  def actor_receive(events, io)
#    case io
#    when @ws
#      @ws.io_event(events, io)
#    else
#      super
#    end
#  end
#
#  def on_bin_frame()
#  end
#
#  def on_text_frame(json:, **args)
#    message_received(json)
#  end
#
#  def message_received(msg)
#    msg.deep_symbolize_keys!
#
#    debug3 { "MSG <<< #{msg}" }
#
#    case msg[:type]
#    when 'keepalive'
#      # Ignore
#    when 'ping'
#      transmit_msg({
#        type: 'pong',
#        request_id: msg[:request_id],
#      })
#    when 'idle'
#      @idle_state = :idle
#      @events_to.tell(MsgIdle.new) if @events_to
#    when 'awake'
#      @idle_state = :awake
#      @events_to.tell(MsgAwake.new) if @events_to
#    when 'req'
#      request_received(msg)
#    when 'req_cancel'
#      # Ignore for now
#    else
#      log.warn { "WS UNHANDLED MESSAGE #{msg}" }
#
#      transmit_msg({
#        type: 'message_not_handled',
#        msg_type: msg[:type],
#        request_id: msg[:request_id],
#      })
#    end
#  end
#
#  class BadRequest < Ygg::Exception ; end
#
#  def request_received(msg)
#    case msg[:verb]
###    when 'auth'
###      handle_auth(msg)
#
#    when 'logout'
#      @session.logout!
#      @session.destroy!
#
#      transmit_req_ok(reply_to: msg)
#
#      @ws.close(cause: AM::WS::Socket::NormalClosure.new(title: 'Closure after logout'))
#
#    when 'set_params'
#      handle_set_params(msg)
#
#    when 'select'
#      handle_select(msg)
#
#    when 'select_unbind'
#      handle_select_unbind(msg)
#
#    when 'get'
#      handle_get(msg)
#
#    when 'getmany'
#      handle_getmany(msg)
#
#    when 'create'
#      handle_create(msg)
#
#    when 'update'
#      handle_update(msg)
#
#    when 'destroy'
#      handle_destroy(msg)
#
#    when 'call'
#      handle_call(msg)
#
#    when 'sub'
#      handle_sub(msg)
#
#    when 'unsub'
#      handle_unsub(msg)
#
#    when 'sub_filter_add'
#    else
#      log.warn { "WS UNHANDLED VERB #{msg[:verb]}" }
#
#      transmit_req_fail(reply_to: msg, body: {
#        type: 'AM::VOS::UnknownVerb',
#      })
#    end
#
#  rescue Ygg::Exception => e
#    # FIXME add base_uri:, make safe_receiver off by default)
#    transmit_req_fail(reply_to: msg, body: e.as_json_problem(safe_receiver: true))
#  rescue ::Exception => e
#    transmit_req_fail(reply_to: msg, body: {
#      type: e.class.name.underscore,
#      title: e.to_s,
#      title_sym: e.class.name.underscore,
#      backtrace: e.backtrace,
#      catcher: 'message_received',
#      is_ygg_exception: true,
#    })
#
#    log.exception e
#  end
#
###  def handle_auth(msg)
###    raise BadRequest.new(title: "Missing body") if !msg[:body]
###
###    if !@session
###      begin
###        @session = AM::VOS::Session.new(
###          ds: @ds,
###          auth_manager: @auth_manager,
###          remote_endpoint: @remote_endpoint_real || @ws.remote_endpoint,
###          headers: @headers,
###        )
###      rescue AM::AuthManager::MsgSessionGetFailure => e
###        transmit_req_fail(reply_to: msg, body: e.as_json_problem)
###        return
###      end
###    end
###
###    begin
###      @session.authenticate(username: msg[:body][:username], password: msg[:body][:password])
###    rescue AM::VOS::Session::FailedAuthentication => e
###      transmit_req_fail(reply_to: msg, body: e.as_json_problem)
###    else
###      transmit_req_ok(reply_to: msg, body: { session: @session.representation })
###    end
###  end
#
#  def handle_set_params(msg)
#    body = msg[:body].dup
#
#    if body.has_key?(:keepalive_method)
#      body[:keepalive_method] = body[:keepalive_method].to_sym
#
#      if ![ :data, :pong, :none ].include?(body[:keepalive_method])
#        transmit_req_fail(reply_to: msg, body: {
#          type: 'AM::VOS::KeepaliveMethodInvalid',
#        })
#        return
#      end
#    end
#
#    @pars.apply(**body)
#
#    if ([ :keepalive_method, :keepalive_time, :keepalive_timeout ] & @pars.changes.keys).any?
#      ws_keepalive_start
#    end
#
#    transmit_req_ok(reply_to: msg)
#  end
#
#  def ws_keepalive_start
#    @ws.keepalive_stop
#
#    case @pars.keepalive_method
#    when :data
#      @ws.keepalive_start(
#        time: @pars.keepalive_time,
#        timeout: @pars.keepalive_timeout,
#        transmit_cb: method(:ws_keepalive_transmit),
#      )
#    when
#      @ws.keepalive_start(
#        time: @pars.keepalive_time,
#        timeout: @pars.keepalive_timeout,
#      )
#    end
#  end
#
#  def ws_keepalive_transmit(**)
#    transmit_msg({ type: 'keepalive' })
#  end
#
#  def handle_select(msg)
#    debug2 { "VOS SELECT REQUEST #{msg} -------------" }
#    puts "VOS SELECT REQUEST #{msg} -------------"
#
#    raise "Body missing" if !msg[:body]
#
#    params = msg[:params] || {}
#    selector = msg[:body]
#
#    object_ids = []
#    object_reps_to_send = []
#
#    selector.each do |se|
#      model = lookup_model(se[:type])
#      ctr_name = model.name + '::VosController'
#
#puts "AAAAAAAAAAAAAAAAA222 #{ctr_name}"
#      ctr = @ctr_cache[ctr_name]
#      if !ctr
#        ctr_cls = nil
#
#        begin
#          ctr_cls = Class.const_get(ctr_name)
#        rescue NameError
#          raise ControllerNotFound
#        end
#
#        ctr = ctr_cls.new(aaa_context: @session)
#      end
#
#      total_res = nil
#      selected_res = nil
#
#      begin
##        ctr.ar_authorize_collection_action(action: :index)
#
#        total_res = ctr.vos_model.all
#
#puts "AAAAAAAAAAAAAAAAAAAAA #{total_res.count}"
#
#        total_res = ctr.vos_filter_by_authorization(total_res)
#        total_res = ctr.vos_apply_filter(total_res, params[:filter]) if params[:filter]
#
#        selected_res = total_res
#        selected_res = selected_res.order(msg[:order]) if msg[:order]
#        selected_res = selected_res.limit(msg[:limit]) if msg[:limit]
#        selected_res = selected_res.offset(msg[:offset]) if msg[:offset]
#
#      rescue ActiveRest::Controller::ResourceNotReadable => e
#        log.exception e
#        raise ResourceNotReadable
#      end
#
#      object_ids += selected_res.map(&:id)
#      objects_to_send = selected_res
#
#      begin
#        object_reps = ctr.ar_render_many(
#          objects_to_send,
#          view: msg[:view],
#          format: msg[:accept] || @pars.accept,
#          meta: { total_count: total_res.count },
#        )
#      rescue ActiveRest::Controller::ResourceNotReadable => e
#        log.exception e
#        raise ResourceNotReadable
#      end
#
#      object_reps_to_send += object_reps[:data]
#    end
#
#
##    # Filter out objects that are already in client's possession
##    if params[:fetch] == false
##      objects_to_send = []
##    elsif params[:fetch_all]
##       objects_to_send = selected_res
##    else
##       objects_to_send = selected_res.to_a.reject { |x| @bindings[model.name] && @bindings[model.name].include?(x.id) }
##    end
#
#
#    transmit_req_ok(reply_to: msg, body: {
#      object_ids: object_ids,
#      objects: object_reps_to_send,
#      relations: [],
#      selection_id: nil,#res.selection_id,
#    })
#  end
#
#  def handle_select_unbind(msg)
#    params = msg[:params] || {}
#
###    res = @ds.ask(AM::DataStore::Store::MsgSelectionUnbind.new(id: params[:selection_id])).value
#
#    transmit_req_ok(reply_to: msg)
#  end
#
#  def handle_get(msg)
#    params = msg[:params]
#    raise BadRequest.new(title: "Missing params") if !params
#    raise BadRequest.new(title: "Missing id from params") if !params[:id]
#
###    res = @ds.ask(AM::DataStore::Store::MsgObjectGet.new(id: params[:id])).value
#
#    transmit_req_ok(reply_to: msg, body: res.object.as_jsonapi)
#  end
#
#  def handle_getmany(msg)
#    params = msg[:params]
#    raise BadRequest.new(title: "Missing params") if !params
#    raise BadRequest.new(title: "Missing ids from params") if !params[:ids]
#
###    res = @ds.ask(AM::DataStore::Store::MsgObjectGetMany.new(ids: params[:ids])).value
#
#    transmit_req_ok(reply_to: msg, body: res.objects.map(&:as_jsonapi))
#  end
#
#  def handle_create(msg)
#    raise "Unimplemented" # TODO
#  end
#
#  def handle_update(msg)
#    params = msg[:params]
#
#    raise BadRequest.new(title: "Missing params") if !params
#    raise BadRequest.new(title: "Missing id from params") if !params[:id]
#    raise BadRequest.new(title: "Missing body") if !msg[:body]
#
##    ctr = @controller_factory.for(msg[:model])
##
##    stuff = ctr.update(object: msg[:object])
#
###    res = @ds.ask(AM::DataStore::Store::MsgObjectUpdate.new(id: params[:id], vals: msg[:body])).value
#
#    transmit_req_ok(reply_to: msg, body: {
#      changes: res.changes,
#    })
#  end
#
#  def handle_destroy(msg)
#    raise "Unimplemented" # TODO
#  end
#
#  def handle_call(msg)
#    obj = nil
#
###    if msg[:params][:object_id]
###        dump = @ds.ask(AM::DataStore::Store::MsgDump.new).value
###      begin
###        obj = @ds.ask(AM::DataStore::Store::MsgObjectGet.new(id: msg[:params][:object_id])).value.object
###      rescue AM::DataStore::Store::MsgObjectGetNotFound => e
###        transmit_req_fail(reply_to: msg, body: {
###          type: 'AM::VOS::ObjectNotFound',
###        })
###
###        return
###      end
###    end
#
#    call_msg = MsgCall.new(
#      object_id: msg[:params][:object_id],
#      method: msg[:params][:method],
#      params: msg[:params][:call_params],
#      body: msg[:body],
#      session_id: @session && @session.id,
#      person_id: @session && @session.person_id,
#      object: obj,
#    )
#
#    req = Request.new(
#      id: msg[:request_id],
#      original_msg: msg,
#      call_message: call_msg,
#    )
#
#    dst = (obj && obj.calls_to) ? obj.calls_to : @calls_to
#
#    if !dst
#      transmit_req_fail(reply_to: msg, body: {
#        type: 'AM::VOS::ConfigurationError',
#      })
#      return
#    end
#
#    @requests << req
#
#    dst.tell(req.call_message, reply_to: self.actor_ref)
#  end
#
#  def handle_sub(msg)
#    params = msg[:params]
#
#    raise BadRequest.new(title: "Missing params") if !params
#    raise BadRequest.new(title: "Missing exchange from params") if !params[:exchange]
#
#    @server.tell(Server::MsgSub.new(exchange: params[:exchange]))
#
#    transmit_req_ok(reply_to: msg, body: {
#    })
#  end
#
#  def handle_unsub(msg)
#    params = msg[:params]
#
#    raise BadRequest.new(title: "Missing params") if !params
#    raise BadRequest.new(title: "Missing exchange from params") if !params[:exchange]
#
#    @server.tell(Server::MsgUnsub.new(exchange: params[:exchange]))
#
#    transmit_req_ok(reply_to: msg, body: {
#    })
#  end
#
#  def transmit_req_ok(reply_to:, body: nil)
#    resp = {
#      type: 'req_ok',
#      request_id: reply_to[:request_id],
#    }
#
#    resp[:body] = body if body
#
#    transmit_msg(resp)
#  end
#
#  def transmit_req_fail(reply_to:, body: nil)
#    resp = {
#      type: 'req_fail',
#      request_id: reply_to[:request_id],
#    }
#
#    resp[:body] = body if body
#
#    transmit_msg(resp)
#  end
#
#  def transmit_msg(msg)
#    debug3 { "MSG >>> #{msg}" }
#
#    begin
#      @ws.transmit_text(msg)
#    rescue Encoding::UndefinedConversionError => e
#      log.error "Exception  #{e} while transmitting text: #{msg.inspect}"
#      raise
#    end
#  end
#
#  def lookup_model(model_name)
#    if model_name =~ /[[:upper:]]/
#      model = model_name.constantize
#    else
#      model = jsonapi_to_class_name(model_name).constantize
#    end
#
#    model
#  rescue NameError
#    raise ModelNotFound
#  end
#
#  def lookup_controller(model)
#    @ctr_cache.get(model.name + '::RestController')
#  rescue NameError
#    raise ControllerNotFound
#  end
#
#  def class_name_to_jsonapi(str)
#    self.class.class_name_to_jsonapi(str)
#  end
#  def self.class_name_to_jsonapi(str)
#    str = str.to_s.underscore
#    str.gsub!(/^\//, '')
#    str.gsub!(/\//, '--')
#    str.gsub!(/_/, '-')
#    str
#  end
#
#  def jsonapi_to_class_name(str)
#    self.class.jsonapi_to_class_name(str)
#  end
#  def self.jsonapi_to_class_name(str)
#    str = str.to_s
#    str.gsub!(/--/, '/')
#    str.gsub!(/-/, '_')
#    str.camelize
#  end
#
#  def disconnected
#    if actor_shutting_down?
#      actor_shutdown_proceed!
#    else
#      debug2 { "Endpoint disconnected abruptly" }
#      actor_exit
#    end
#  end
#
#  def actor_shutdown_start
#    @events_to.tell(MsgDisconnected.new) if @events_to
#
#    if @ws && !@ws.disconnected?
#      @ws.close(cause: AM::WS::Socket::LocalClosure.new(code: 1001, title: 'Server being shut down'))
#    else
#      super
#    end
#  end
#
#  def actor_finalize
#    @ws.finalize
#  end
#
#  def actor_crashed!(exception:)
#    begin
#      transmit_msg({
#        type: 'exception',
#        body: {
#          type: exception.class.name.underscore,
#          title: exception.to_s,
#          title_sym: exception.class.name.underscore,
#          backtrace: exception.backtrace,
#          catcher: 'actor_crashed',
#          is_ygg_exception: true,
#        },
#      })
#    rescue StandardError => e
#    end
#
#    super
#  end
#end
#
#end
#end
#
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
#### frozen_string_literal: true
####
#### Copyright (C) 2015-2023, Daniele Orlandi
####
#### Author:: Daniele Orlandi <daniele@orlandi.com>
####
#### License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
####
###
###require 'active_rest/controller/cache'
###require 'am/ws'
###require 'ygg/diffable'
###require 'am/ws/server_socket'
###
###  include AM::Actor
###
###  class MsgClose < AM::Msg
###    attr_accessor :code
###  end
###
###  class MsgSetOnline < AM::Msg
###    attr_accessor :online
###    attr_accessor :offline_reason
###  end
###
###  class MsgModelPublish < AM::Msg
###    attr_accessor :routing_key
###    attr_accessor :exchange
###    attr_accessor :headers
###    attr_accessor :object
###    attr_accessor :object_type
###    attr_accessor :object_id
###    attr_accessor :events
###    attr_accessor :xact_id
###    attr_accessor :person_id
###    attr_accessor :credential_id
###    attr_accessor :http_request_id
###  end
###
###  class Selection
###    attr_accessor :model
###    attr_accessor :filter
####    attr_accessor :partial
###    attr_accessor :bind_new
###
###    def initialize(**args)
###      args.each { |k,v| send("#{k}=", v) }
###    end
###  end
###
###
###
###  def initialize(env:, socket:, headers:, session:, routes_config:, debug:, **args)
###    @env = env
###    @socket = socket
###    @headers = headers
###    @session = session
###    @routes_config = routes_config
###    @debug = debug
###
###    raise "Gateway missing" if !AM::Registry[:rails_vos]
###
###    actor_initialize(monitored_by: AM::Registry[:rails_vos], **args)
###  end
###
###  class Parameters
###    include Ygg::Diffable
###
###    d_attr_accessor :keepalive_time
###    d_attr_accessor :keepalive_timeout
###    d_attr_accessor :keepalive_method
###    d_attr_accessor :accept
###    d_attr_accessor :content_type
###  end
###
###  def actor_boot
###    @online = false
###    @idle_state = :unknown
###
###    @subs = {}
###    @subs_by_exchange = {}
###    @exchanges = {}
###
###    @model_exchange_bound = false
###    @selections = {}
###    @selections_by_model = {}
###    @bindings = {}
###
###    @ctr_cache = ActiveRest::Controller::Cache.new(aaa_context: @session)
###
###    @socket_peeraddr = @socket.peeraddr
###
###    actor = AM::Registry[:rails_vos].send(:actor)
###
###    @register_fut = AM::Registry[:rails_vos].ask(Gateway::MsgRegisterConnection.new(
###      session_id: @session ? @session.id : nil,
###      remote_addr: @socket.remote_address.ip_address,
###      remote_port: @socket.remote_address.ip_port,
###    ))
###
###    debug2 { "WS #{remote_name}: Actor booting" }
###
###    @pars = Parameters.new(
###      keepalive_time: 5,
###      keepalive_timeout: 10,
###      keepalive_method: :pong,
###      accept: 'application/vnd.api+json',
###      content_type: 'application/vnd.api+json',
###    )
###
###    @conn = AM::WS::ServerSocket.new(
###      socket: @socket,
###      headers: @headers,
###      protocol: 'vos.vihai.it',
###      auto_json: true,
###      actor: self,
###      debug: @debug,
###    )
###
###    @conn.on_ready = method(:conn_ready)
###    @conn.on_text_frame = method(:on_text_frame)
###    @conn.on_bin_frame = method(:on_bin_frame)
###    @conn.on_disconnected = method(:disconnected)
###
###    @conn.start
###
####    @driver.on(:close) do |e|
####
####      debug1 { "WS #{remote_name}: Closed" }
####
####      @socket.close
####
####      @exchanges.each do |ex_name, ex|
####        debug1 { "WS #{remote_name}: Unsubscribing #{ex_name}" }
####
####        AM::Registry[:rails_vos].tell(Gateway::MsgUnsubscribe.new(exchange_name: ex_name))
####      end
####
####      @socket = nil
####
####      actor_exit
####    end
####
####    actor_io_add(@socket, SleepyPenguin::Epoll::IN)
####
####    @driver.start
###  end
###
###  def conn_ready
###    debug1 { "WS #{remote_name}: Connection open" }
###
###    res = nil
###    begin
###      res = @register_fut.value(timeout: 3.seconds)
###    rescue Timeout::Error
###      @online = false
###      @offline_reason = "Cannot contact RAILS/AMQP gateway"
###    else
###      @online = res.online
###      @offline_reason = res.offline_reason
###    end
###
###    if @session
###      # FIXME there is a slight chance that the session changes before we subscribe
###      create_persistent_selection(model: Ygg::Core::HttpSession, filter: { id: @session.id })
###    end
###
###    transmit({
###      type: 'welcome',
###      session_id: @session ? @session.id : nil,
###      online: @online,
###      offline_reason: @offline_reason,
###      app_version: Rails.application.config.app_version,
###    })
###
###    ws_keepalive_start
###  end
###
###  def ws_keepalive_start
###    @conn.keepalive_stop
###
###    case @pars.keepalive_method
###    when :data
###      @conn.keepalive_start(
###        time: @pars.keepalive_time,
###        timeout: @pars.keepalive_timeout,
###        transmit_cb: method(:ws_keepalive_transmit),
###      )
###    when
###      @conn.keepalive_start(
###        time: @pars.keepalive_time,
###        timeout: @pars.keepalive_timeout,
###      )
###    end
###  end
###
###  def ws_keepalive_transmit(**)
###    transmit({ type: 'keepalive' })
###  end
###
###  def on_bin_frame()
###  end
###
###  def on_text_frame(json:, **args)
###    message_received(json)
###  end
###
###  def actor_crashed!(exception:)
###    begin
###      transmit({
###        type: 'exception',
###        content_type: 'application/problem+json',
###        catcher: 'actor_crashed',
###        payload: {
###          type: exception.class.name.underscore,
###          title: exception.to_s,
###          title_sym: exception.class.name.underscore,
###          backtrace: exception.backtrace,
###        },
###      })
###    rescue StandardError => e
###    end
###
###    super
###  end
###
###  def actor_finalize
###    @conn.finalize
###  end
###
###  def remote_name
###    "#{@socket_peeraddr[2]}:#{@socket_peeraddr[1]}"
###  end
###
###  def message_received(msg)
###    msg = msg.deep_symbolize_keys
###
###    case msg[:type]
###    when 'ping'
###      transmit({
###        type: 'pong',
###        reply_to: msg[:request_id],
###      })
###
###    when 'idle'
###      @idle_state = :idle
###
###    when 'awake'
###      @idle_state = :awake
###
###    when 'set_params'
###      handle_set_params(msg)
###
###    when 'select'
###      handle_select(msg)
###
###    when 'select_ubind'
###      handle_select_unbind(msg)
###
###    when 'get'
###      handle_get(msg)
###
###    when 'getmany'
###      handle_getmany(msg)
###
###    when 'create'
###      handle_create(msg)
###
###    when 'update'
###      handle_update(msg)
###
###    when 'destroy'
###      handle_destroy(msg)
###
###    when 'unbind'
###      handle_unbind(msg)
###
###    when 'sub'
###      subscription_request(msg)
###
###    when 'unsub'
###      unsubscription_request(msg)
###
###    when 'sub_filter_add'
###      sub = @subs[msg[:sub_id]]
###      if sub
###        msg[:filters].each do |filter_name, filter_config|
###          sub.filters[filter_name].add(filter_config)
###        end
###
###        transmit({
###          type: 'sub_filter_add_ok',
###          reply_to: msg[:request_id],
###        })
###      else
###        transmit({
###          type: 'sub_filter_add_fail',
###          reply_to: msg[:request_id],
###        })
###      end
###
###    when 'sub_filter_del'
###      sub = @subs[msg[:sub_id]]
###      if sub
###        msg[:filters].each do |filter_name, filter_config|
###          sub.filters[filter_name].del(filter_config)
###        end
###
###        transmit({
###          type: 'sub_filter_del_ok',
###          reply_to: msg[:request_id],
###        })
###      else
###        transmit({
###          type: 'sub_filter_del_fail',
###          reply_to: msg[:request_id],
###        })
###      end
###    else
###      log.warn { "WS UNHANDLED MESSAGE #{msg}" }
###
###      transmit({
###        type: 'message_not_handled',
###        reply_to: msg[:request_id],
###        unhandled_message: msg[:type],
###      })
###    end
###  rescue Ygg::Exception => e
###    transmit({
###      type: 'exception',
###      reply_to: msg[:request_id],
###      content_type: 'application/problem+json',
###      payload: e.as_json_problem(safe_receiver: Rails.application.config.rails_vos.safe_receiver), # FIXME add base_uri:
###      catcher: 'message_received',
###      is_ygg_exception: true,
###    })
###  rescue ::Exception => e
###    transmit({
###      type: 'exception',
###      reply_to: msg[:request_id],
###      content_type: 'application/problem+json',
###      payload: {
###        type: e.class.name.underscore,
###        title: e.to_s,
###        title_sym: e.class.name.underscore,
###        backtrace: e.backtrace,
###      },
###      catcher: 'message_received',
###      is_ygg_exception: true,
###    })
###
###    log.exception e
###  end
###
###  def handle_set_params(msg)
###    body = msg[:body].dup
###
###    if body.has_key?(:keepalive_method)
###      body[:keepalive_method] = body[:keepalive_method].to_sym
###
###      if ![ :data, :pong, :none ].include?(body[:keepalive_method])
###        transmit_req_fail(reply_to: msg, body: {
###          type: 'AM::VOS::KeepaliveMethodInvalid',
###        })
###        return
###      end
###    end
###
###    if body[:default_accept]
###      body[:accept] = body.delete(:default_accept)
###    end
###
###    if body[:default_content_type]
###      body[:content_type] = body.delete(:default_content_type)
###    end
###
###    @pars.apply(**body)
###
###    if ([ :keepalive_method, :keepalive_time, :keepalive_timeout ] & @pars.changes.keys).any?
###      ws_keepalive_start
###    end
###
###    #transmit_req_ok(reply_to: msg)
###  end
###
###  # Create a selection of objects and return whole or part of it
###  #
###  # Message parameters:
###  # model:        Model name
###  # params:       
###  #   filter:     
###  # limit:        
###  # offset:       
###  # order:        
###  # view:         
###  # bind:         
###  # persistent:   Create a persistent selection and return a selection_id
###  # fetch:        
###  # fetch_all:    Retrieve objects already bound
###
###  def handle_select(msg)
###    debug1 { "WS SELECT REQUEST #{msg}" }
###
###   # FIXME: use something like routes to find the controller, otherwise the client may use names not meant to be available as controllers
###
###    model = lookup_model(msg[:model])
###    ctr = lookup_controller(model)
###
###    params = msg[:params] || {}
###
###    total_res = nil
###    selected_res = nil
###    begin
###      # This will be moved in ws-reserved methods in rails-controller
###
###      ctr.ar_authorize_collection_action(action: :index)
###
###      total_res = ctr.ar_model.all
###      total_res = ctr.ar_filter_by_authorization(total_res)
###      total_res = ctr.ar_apply_filter(total_res, params[:filter]) if params[:filter]
###
###      selected_res = total_res
###      selected_res = selected_res.order(msg[:order]) if msg[:order]
###      selected_res = selected_res.limit(msg[:limit]) if msg[:limit]
###      selected_res = selected_res.offset(msg[:offset]) if msg[:offset]
###
###    rescue ActiveRest::Controller::ResourceNotReadable => e
###      log.exception e
###      raise ResourceNotReadable
###    end
###
###    object_ids = selected_res.map(&:id)
###
###    # Filter out objects that are already in client's possession
###    if msg[:fetch] == false
###      objects_to_send = []
###    elsif msg[:fetch_all]
###       objects_to_send = selected_res
###    else
###       objects_to_send = selected_res.to_a.reject { |x| @bindings[model.name] && @bindings[model.name].include?(x.id) }
###    end
###
###    if msg[:bind]
###      do_bind(model_name: model.name, ids: object_ids.map(&:to_s))
###    end
###
###    begin
###      object_reps = ctr.ar_render_many(
###        objects_to_send,
###        view: msg[:view],
###        format: msg[:accept] || @pars.accept,
###        meta: { total_count: total_res.count },
###      )
###    rescue ActiveRest::Controller::ResourceNotReadable => e
###      log.exception e
###      raise ResourceNotReadable
###    end
###
###    resp = {
###      type: 'select_ok',
###      reply_to: msg[:request_id],
###      ids: object_ids,
###      objects: object_reps,
###    }
###
###    if msg[:persistent]
###      selection = create_persistent_selection(
###        model: model,
###        filter: msg[:filter],
####        partial: !!(limit || ofset),
###        bind_new: msg[:bind_new].nil? ? true : msg[:bind_new],
###      )
###
###      resp[:selection_id] = selection.object_id
###    end
###
###    transmit(resp)
###  end
###
###  def handle_select_unbind(msg)
###    debug1 { "WS SELECT_UNBIND REQUEST #{msg}" }
###
###    destroy_persistent_selection(selection_id: msg[:selection_id])
###
###    transmit({
###      type: 'select_unbind_ok',
###      reply_to: msg[:request_id],
###    })
###  end
###
###  def handle_get(msg)
###    debug1 { "WS GET REQUEST #{msg}" }
###
###   # FIXME: use something like routes to find the controller, otherwise the client may use names not meant to be available as controllers
###
###    model = lookup_model(msg[:model])
###    ctr = lookup_controller(model)
###
###    representation = nil
###    begin
###      resource = ctr.ar_find_one(msg[:id])
###      representation = ctr.ar_render_one(resource, view: msg[:view], format: msg[:accept] || @pars.accept)
###    rescue ActiveRest::Controller::ResourceNotReadable => e
###log.exception e
###      raise ResourceNotReadable
###    rescue ActiveRecord::RecordNotFound => e
###      raise ResourceNotFound
###    end
###
###    if msg[:bind] != false
###      do_bind(model_name: model.name, id: msg[:id].to_s)
###    end
###
###    transmit({
###      type: 'get_ok',
###      reply_to: msg[:request_id],
###      object: representation,
###    })
###  end
###
###  def handle_getmany(msg)
###    debug1 { "WS GET REQUEST #{msg}" }
###
###   # FIXME: use something like routes to find the controller, otherwise the client may use names not meant to be available as controllers
###
###    model = lookup_model(msg[:model])
###    ctr = lookup_controller(model)
###
###    representations = nil
###    begin
###      resources = ctr.ar_find_many(msg[:ids])
###      representations = ctr.ar_render_many(resources, view: msg[:view], format: msg[:accept] || @pars.accept)
###    rescue ActiveRest::Controller::ResourceNotReadable => e
###log.exception e
###      raise ResourceNotReadable
###    end
###
###    if msg[:bind]
###      do_bind(model_name: model.name, ids: msg[:ids].map(&:to_s))
###    end
###
###    transmit({
###      type: 'getmany_ok',
###      reply_to: msg[:request_id],
###      objects: representations,
###    })
###  end
###
###  def handle_create(msg)
###    debug1 { "WS CREATE REQUEST #{msg}" }
###
###    raise MissingObject if !msg[:object]
###    model = lookup_model(msg[:model])
###    ctr = lookup_controller(model)
###    request_id = SecureRandom.uuid
###
###    begin
###      resource = ctr.ws_create(resource_object: msg[:object], format: :jsonapi, request_id: request_id)
###    rescue ActiveRest::Controller::ResourceNotWritable => e
###      raise ResourceNotWritable
###    rescue ActiveRest::Controller::AttributeNotWritable => e
###      raise AttributeNotWritable.new(data: { attribute_name: e.attribute_name })
###    rescue ActiveRest::Controller::AttributeNotFound => e
###      raise AttributeNotWritable.new(data: { attribute_name: e.attribute_name })
###      raise AttributeNotFound.new(data: { attribute_name: e.attribute_name })
###    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
###      raise ResourceNotValid.new(data: e.record.errors)
###    else
###      transmit({
###        type: 'create_ok',
###        reply_to: msg[:request_id],
###        object: ctr.ar_render_one(resource, format: msg[:accept] || @pars.accept),
###      })
###    end
###
###    if msg[:bind]
###      do_bind(model_name: model.name, id: resource.id.to_s)
###    end
###  end
###
###  def handle_update(msg)
###    debug1 { "WS UPDATE REQUEST #{msg}" }
###
###    raise MissingObject if !msg[:object]
###    raise MissingObjectData if !msg[:object][:data]
###    raise MissingObjectDataId if !msg[:object][:data][:id]
###    model = lookup_model(msg[:model])
###    ctr = lookup_controller(model)
###    request_id = SecureRandom.uuid
###
###    begin
###      resource = ctr.ar_find_one(msg[:object][:data][:id])
###      ctr.ws_update(resource, resource_object: msg[:object], format: :jsonapi, request_id: request_id)
###    rescue ActiveRest::Controller::ResourceNotWritable => e
###      raise ResourceNotWritable
###    rescue ActiveRest::Controller::AttributeNotWritable => e
###      raise AttributeNotWritable.new(data: { attribute_name: e.attribute_name })
###    rescue ActiveRest::Controller::AttributeNotFound => e
###      raise AttributeNotFound.new(data: { attribute_name: e.attribute_name })
###    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
###      raise ResourceNotValid.new(data: e.record.errors)
###    else
###      transmit({
###        type: 'update_ok',
###        reply_to: msg[:request_id],
###        object: ctr.ar_render_one(resource, format: msg[:accept] || @pars.accept),
###      })
###    end
###  end
###
###  def handle_destroy(msg)
###    debug1 { "WS DESTROY REQUEST #{msg}" }
###
###    raise MissingId if !msg[:id]
###    model = lookup_model(msg[:model])
###    ctr = lookup_controller(model)
###    request_id = SecureRandom.uuid
###
###    begin
###      # This will be moved in ws-reserved methods in rails-controller
###      resource = ctr.ar_find_one(msg[:id])
###      ctr.ws_destroy(resource, request_id: request_id)
###    rescue ActiveRest::Controller::ResourceNotWritable => e
###      raise ResourceNotWritable
###    else
###      transmit({
###        type: 'destroy_ok',
###        reply_to: msg[:request_id],
###      })
###    end
###
###    do_unbind(model: model, id: msg[:id])
###  end
###
###  def do_bind(model_name:, id: nil, ids: nil)
###    @bindings[model_name] ||= Set.new
###    @bindings[model_name] << id if id
###    @bindings[model_name] += ids if ids
###
###    eventually_subscribe_models_exchange
###  end
###
###  def create_persistent_selection(model:, filter: nil, bind_new: true)
###    binding = Selection.new(model: model.name, filter: filter, bind_new: bind_new)
###    binding_id = binding.object_id
###    @selections[binding_id] = binding
###
###    @selections_by_model[model.name] ||= []
###    @selections_by_model[model.name] << binding
###
###    eventually_subscribe_models_exchange
###
###    binding
###  end
###
###  def destroy_persistent_selection(selection_id:)
###    selection = @selections.delete(selection_id)
###
###    @selections_by_model[selection.model].delete(selection)
###    @selections_by_model.delete(selection.model) if @selections_by_model[selection.model].empty?
###
###    eventually_unsubscribe_models_exchange
###  end
###
###  def handle_unbind(msg)
###    debug1 { "WS UNBIND REQUEST #{msg}" }
###
###    model = lookup_model(msg[:model])
###
###    do_unbind(model: model, id: msg[:id], ids: msg[:ids])
###
###    transmit({
###      type: 'unbind_ok',
###      reply_to: msg[:request_id],
###    })
###  end
###
###  def do_unbind(model:, id: nil, ids: nil)
###    if @bindings[model.name]
###      @bindings[model.name].delete(id) if id
###      @bindings[model.name].subtract(ids) if ids
###
###      if @bindings[model.name].empty?
###        @bindings.delete(model.name)
###      end
###
###      eventually_unsubscribe_models_exchange
###    end
###
###    nil
###  end
###
###  def eventually_subscribe_models_exchange
###    if !@model_exchange_bound
###      subscribe_exchange('ygg.model.events')
###      @model_exchange_bound = true
###    end
###  end
###
###  def eventually_unsubscribe_models_exchange
###    if @bindings.empty? && @selections.empty?
###      unsubscribe_exchange('ygg.model.events')
###      @model_exchange_bound = false
###    end
###  end
###
###  def subscribe_exchange(exchange)
###    debug1 { "SUBSCRIBE EXCHANGE #{exchange}" }
###    if !@exchanges[exchange]
###      @exchanges[exchange] = 0
###      AM::Registry[:rails_vos].tell(Gateway::MsgSubscribe.new(exchange_name: exchange))
###    end
###
###    @exchanges[exchange] += 1
###  end
###
###  def unsubscribe_exchange(exchange)
###    return if !@exchanges[exchange]
###
###    @exchanges[exchange] -= 1
###
###    if @exchanges[exchange] == 0
###      @exchanges.delete(exchange)
###      AM::Registry[:rails_vos].tell(Gateway::MsgUnsubscribe.new(exchange_name: exchange))
###    end
###  end
###
###  def subscription_request(msg)
###    debug1 { "WS #{remote_name}: subscribe to #{msg[:exchange]}" }
###
###    raise MissingExchange if !msg[:exchange]
###
###    if !@routes_config[msg[:exchange].to_sym]
###      raise RouteNotConfigured
###    end
###
###    if (!@session || !@session.authenticated?) && !@routes_config[msg[:exchange].to_sym][:anonymous_access]
###      raise AuthenticationRequired
###    end
###
###    begin
###      sub = Subscription.new(exchange: msg[:exchange], filters_config: msg[:filters] || {})
###
###    rescue Subscription::UnknownFilter => e
###      transmit({
###        type: 'exception',
###        reply_to: msg[:request_id],
###        content_type: 'application/problem+json',
###        exchange: msg[:exchange],
###        reason: e.to_s,
###        backtrace: e.backtrace,
###      })
###    else
###      # Register the subscription
###      @subs[sub.object_id] = sub
###      @subs_by_exchange[msg[:exchange]] ||= []
###      @subs_by_exchange[msg[:exchange]] << sub
###
###      subscribe_exchange(msg[:exchange])
###
###      transmit({
###        type: 'sub_ok',
###        reply_to: msg[:request_id],
###        sub_id: sub.object_id,
###      })
###    end
###  end
###
###  def unsubscription_request(msg)
###    sub = @subs[msg[:sub_id]]
###    if sub
###      debug1 { "WS #{remote_name}: unsubscribe from #{sub.exchange}" }
###
###      @subs.delete(msg[:sub_id])
###      @subs_by_exchange[sub.exchange].delete(sub)
###      @subs_by_exchange.delete(sub.exchange) if @subs_by_exchange[sub.exchange].empty?
###
###      unsubscribe_exchange(sub.exchange)
###
###      transmit({
###        type: 'unsub_ok',
###        reply_to: msg[:request_id],
###      })
###    else
###      debug1 { "WS #{remote_name}: sub #{msg[:sub_id]} not found for unsubscribe" }
###
###      raise SubscriptionNotFound
###    end
###  end
###
###  def actor_receive(events, io)
###    case io
###    when @conn
###      @conn.io_event(events, io)
###    else
###      super
###    end
###  end
###
###  def transmit(data)
###    @conn.transmit_text(data)
###  end
###
###  def actor_handle(msg)
###    case msg
###    when MsgClose
####      @driver.close(msg.reason || '', msg.code || 1000)
###      @conn.close
###    when MsgSetOnline
###      if msg.online
###        transmit({
###          type: 'online',
###        })
###      else
###        transmit({
###          type: 'offline',
###          offline_reason: msg.offline_reason.to_s,
###        })
###      end
###
###    when MsgPublish
###      if @exchanges[msg.exchange] && @subs_by_exchange[msg.exchange]
###        subs = @subs_by_exchange[msg.exchange].select { |x| x.filters.all? { |k,v| v.match?(msg) } }
###
###        if subs.any?
###          transmit({
###            type: 'msg',
###            sub_ids: subs.collect(&:object_id),
###            routing_key: msg.routing_key,
###            exchange: msg.exchange,
###            headers: msg.headers,
###            payload: msg.payload,
###          })
###        end
###      end
###
###    when MsgModelPublish
###      # Take note if session has been changed
###      if msg.object == @session
###        if msg.events.include?('D')
###          @session = nil
###          @ctr_cache.clear!
###        else
###          @session.reload
###          @ctr_cache.clear!
###        end
###      end
###
###      to_be_sent = false
###
###      if @bindings[msg.object_type] && @bindings[msg.object_type].include?(msg.object_id.to_s)
###        to_be_sent = true
###      elsif msg.events.include?('C')
###        selections = @selections_by_model[msg.object_type]
###        if selections
###          if selections.any? { |sel| !sel.filter || sel.filter.all? { |k,v| msg.object.send(k) == v } }
###            to_be_sent = true
###           end
###
###           if selections.any? { |sel| sel.bind_new }
###             do_bind(model_name: msg.object_type, id: msg.object_id.to_s)
###           end
###        end
###      end
###
###      if to_be_sent
###        object_rendered = nil
###
###        ActiveRecord::Base.connection_pool.with_connection do
###          object = msg.object
###          if object
###            ctr = @ctr_cache.get(object.class.name + '::RestController')
###
###            begin
###              object_rendered = ctr.ar_render_one(object, format: @pars.accept)
###            rescue ActiveRest::Controller::ResourceNotReadable
###              return
###            end
###          end
###        end
###
###        type = if msg.events.include?('D')
###          'destroy'
###        elsif msg.events.include?('C')
###          'create'
###        else
###          'update'
###        end
###
###        formatted_object_type = if @pars.content_type == 'application/vnd.api+json'
###          class_name_to_jsonapi(msg.object_type)
###        else
###          msg.object_type
###        end
###
###        transmit(
###          type: type,
###          routing_key: msg.routing_key,
###          exchange: msg.exchange,
###          headers: msg.headers,
###          object: object_rendered,
###          object_type: formatted_object_type,
###          object_id: msg.object_id,
###          xact_id: msg.xact_id,
###          person_id:   msg.person_id,
###          credential_id: msg.credential_id,
###          http_request_id: msg.http_request_id,
###        )
###      end
###
###    else
###      super
###    end
###  end
###
###  def disconnected
###    actor_exit
###  end
###
###  def actor_shutdown
###    @conn.close if @conn
###  end
###
###  def secure_request?
###    return true if env['HTTPS'] == 'on'
###    return true if env['HTTP_X_FORWARDED_SSL'] == 'on'
###    return true if env['HTTP_X_FORWARDED_SCHEME'] == 'https'
###    return true if env['HTTP_X_FORWARDED_PROTO'] == 'https'
###    return true if env['rack.url_scheme'] == 'https'
###
###    return false
###  end
###
###  # Needed by websocket-driver
###  def url
###    "#{secure_request? ? 'wss' : 'ws'}://#{@env['HTTP_HOST']}#{@env['REQUEST_URI']}"
###  end
###
###  # Needed by websocket-driver
###  def write(data)
###    @socket.write(data) # XXX buffer
###  end
###
###  # Needed by websocket-driver
###  def env
###    @env
###  end
###
###  def debug1(&block) ; log.debug block.call if @debug >= 1 ; end
###  def debug2(&block) ; log.debug block.call if @debug >= 2 ; end
###  def debug3(&block) ; log.debug block.call if @debug >= 3 ; end
###
###  class Subscription
###    attr_accessor :exchange
###    attr_accessor :filters
###
###    class UnknownFilter < StandardError ; end
###
###    def initialize(filters_config:, **args)
###      @filters = {}
###
###      args.each { |k,v| send("#{k}=", v) }
###
###      filters_config.each do |filter_name, config|
###        begin
###          klass = "::Ygg::AmqpWsGw::WsConnection::Subscription::#{filter_name.capitalize}Filter".constantize
###        rescue NameError
###          raise UnknownFilter
###        end
###
###        @filters[filter_name] = klass.new(config)
###      end
###    end
###
###    class JsonFilter
###      def initialize(config)
###        @subs = {}
###
###        set(config)
###      end
###
###      def set(config)
###        @subs = {}
###        add(config)
###      end
###
###      def add(config)
###        @config = config.deep_symbolize_keys
###      end
###
###      def del(config)
###        @config = {}
###      end
###
###      def match?(msg)
###
###        h = {
###          routing_key: msg.routing_key,
###          exchange: msg.exchange,
###          headers: msg.headers,
###          payload: msg.payload,
###        }
###
###        rec_match(h, @config)
###      end
###
###      def rec_match(h, c)
###        c.each do |k,v|
###          if h[k.to_sym]
###            case v
###            when Hash
###              return false if !rec_match(h[k.to_sym], v)
###            when Array
###              return false if !v.include?(h[k.to_sym])
###            else
###              return false if h[k.to_sym] != v
###            end
###          else
###            return false
###          end
###        end
###
###        return true
###      end
###    end
###  end
###
###end
###
###end
