# frozen_string_literal: true
#
# Copyright (C) 2016-2023, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'actor_model'
require 'deep_open_struct'

require 'rails_vos/server/connection'

require 'am/vos/server'

module RailsVos

class Server
  include AM::Actor

  class Ref < AM::ActorRef
    def get_connections
      ask(MsgGetConnections.new).value
    end
  end

  self.actor_ref_class = Ref

##  class MsgNewConnection < AM::Msg
##    attr_accessor :env
##    attr_accessor :session
##    attr_accessor :headers
##    attr_accessor :socket
##    attr_accessor :routes_config
##    attr_accessor :debug
##  end

#  class MsgCall < AM::Msg
#    attr_accessor :object_id
#    attr_accessor :method
#    attr_accessor :params
#    attr_accessor :body
#    attr_accessor :session_id
#    attr_accessor :person_id
#    attr_accessor :object
#  end
#  class MsgCallOk < AM::Msg
#    attr_accessor :body
#  end
#  class MsgCallFail < AM::MsgException
#  end

#  # Sent from Connection(s) to subscribe to an exchange
#  #
#  class MsgSub < AM::Msg
#    attr_accessor :exchange
#  end
#
#  class MsgUnsub < AM::Msg
#    attr_accessor :exchange
#  end


  class MsgGetConnections < AM::Msg
  end
  class MsgGetConnectionsReply < AM::Msg
    attr_accessor :connections
  end

  class MsgGetState < AM::Msg
  end
  class MsgGetStateResponse < AM::Msg
    attr_accessor :idle_state
  end

  module DS
  end

#  class MsgSubscribe < AM::Msg
#    attr_accessor :exchange_name
#  end
#
#  class MsgUnsubscribe < AM::Msg
#    attr_accessor :exchange_name
#  end

  def initialize(routes_config:)
    @routes_config = DeepOpenStruct.new(routes_config)

    super(actor_id: :rails_vos_server)
  end

  def actor_boot
    @instance_id = SecureRandom.uuid

    @conns = []

#    @routes = {}
#    @queues = {}

    @ds = actor_supervise_new(AM::GrafoStore::Store, config: {
      actor_id: :ds,
      hooks: ::Ygg::Core::Grafo,
    }, shut_order: 1000)

    @vos = actor_supervise_new(AM::VOS::Server, config: {
      actor_id: :vos,
      class_base: ::Object, ####################################### FIMXE
      welcome_extra_params: {
        app_version: '0.0.0',
        server_identifier: Rails.application.class.module_parent_name,
      },
      ds: @ds,
      auth_manager: nil,
      calls_to: self.actor_ref,
      events_to: self.actor_ref,
      debug: @debug,
    }, shut_order: 100)

    @amqp = RailsAmqp::Connection.connection
    @amqp.tell(AM::Actor::MsgMonitor.new)

    begin
      ActiveRecord::Base.connection_pool.checkout(5)
    rescue ActiveRecord::ConnectionTimeoutError
      @online = false
      @offline_reason = 'DB non available'
      return
    end

    begin
      @amqp.ask(AM::AMQP::Client::MsgConnect.new).value
    rescue AM::AMQP::Client::MsgConnectFailure => e
      @online = false
      @offline_reason = 'AMQP non available'
      return
    end

    begin
      open_channels
    rescue StandardError => e
      log.fatal "Permanent failure while initializing AMPQ: #{e}"

#      Airbrake[:default].notify("Permanent failure while initializing AMPQ: #{e}") do |notice|
#        notice[:context][:component] = self.class.name
#        notice[:context][:severity] = 'critical'
#      end

      @online = false
      return
    end

    @online = true

  rescue Exception => e
    puts "RailsVos Crash: #{e}"
    puts e.backtrace
  end

  def open_channels
    @amqp_chan = @amqp.ask(AM::AMQP::Client::MsgChannelOpen.new).value.channel_id
    @amqp.ask(AM::AMQP::Client::MsgConfirmSelect.new(channel_id: @amqp_chan)).value

    @routes_config.each do |ex_name, ex|

      if ex.queue && !@queues[ex.queue.name]
        queue_name = @amqp.ask(AM::AMQP::Client::MsgQueueDeclare.new(
          channel_id: @amqp_chan,
          name: "#{ex.queue.name}.#{Process.pid}",
          passive: ex.queue.passive || false,
          durable: ex.queue.durable || false,
          exclusive: ex.queue.exclusive || true,
          auto_delete: ex.queue.auto_delete || true,
          arguments: ex.queue.arguments.to_h || {},
        )).value.name

        @queues[queue_name] = true
      end

      @amqp.ask(AM::AMQP::Client::MsgExchangeDeclare.new(
        channel_id: @amqp_chan,
        name: ex_name.to_s,
        type: ex.type || :topic,
        passive: ex.passive || false,
        durable: ex.durable || true,
        auto_delete: ex.auto_delete || false,
        internal: ex.internal || false,
        arguments: ex.arguments.to_h || {},
      )).value

      consumer_tag  = @amqp.ask(AM::AMQP::Client::MsgConsume.new(channel_id: @amqp_chan, queue_name: queue_name, send_to: actor_ref)).value.consumer_tag

      @routes[ex_name.to_s] = {
        queue: queue_name,
        exchange: ex_name.to_s,
        handler: ex.handler,
        consumer_tag: consumer_tag,
        routing_key: ex.routing_key || '#',
        refcount: 0,
      }
    end
  end

  def actor_handle(msg)

puts "ACTOR HANDLE #{msg}"

    case msg
    when AM::VOS::Server::MsgCall
      actor_reply(msg, AM::VOS::Server::MsgCallFail.new)

    when AM::VOS::Server::MsgClassCall

      begin
        body = msg.cls.send(**msg.params)
      rescue StandardError => e
        actor_reply(msg, AM::VOS::Server::MsgCallFail.new(cause: e))
      else
        actor_reply(msg, AM::VOS::Server::MsgCallOk.new(body: body))
      end

    when AM::HTTP::Server::MsgRequest
      actor_redirect(msg, @vos)

#      conn = actor_supervise_new(Connection, config: {
#        server: self.actor_ref,
#        socket: msg.socket,
#        remote_endpoint_real: AM::Sockets::Endpoint.from_addrinfo(msg.socket.remote_address),
#        instance_id: @instance_id,
#        welcome_extra_params: {},
#        headers: msg.headers,
#        session: msg.session,
#        calls_to: @calls_to,
#        events_to: @events_to,
#        monitored_by: self,
#        debug: @debug,
#      }, crash_action: :none, exit_action: :none)

#      @conns << conn

#    when MsgSub
#      route = @routes[msg.exchange]
#      return if !route
#
#      if route[:refcount] == 0
#        @amqp.ask(AM::AMQP::Client::MsgQueueBind.new(channel_id: @amqp_chan, queue_name: route[:queue],
#                      exchange_name: route[:exchange], routing_key: route[:routing_key])).value
#      end
#
#      route[:refcount] += 1
#
#    when MsgUnsub
#      route = @routes[msg.exchange]
#      return if !route
#
#      if route[:refcount] > 0
#        route[:refcount] -= 1
#
#        if route[:refcount] == 0
#          @amqp.ask(AM::AMQP::Client::MsgQueueUnbind.new(channel_id: @amqp_chan, queue_name: route[:queue],
#                        exchange_name: route[:exchange], routing_key: route[:routing_key])).value
#        end
#      end
#
#    when AM::AMQP::Client::MsgQueueBindFailure
#      log.error "Bind failure: #{msg}"
#
#    when AM::AMQP::Client::MsgQueueUnbindFailure
#      log.error "Unbind failure: #{msg}"

    when AM::AMQP::Client::MsgOperationalStateChange
      if msg.state == :bad
        @online = false
      else
        @online = true
      end
      @conns.each do |conn|
        conn.tell(Connection::MsgSetOnline.new(online: @online, offline_reason: 'AMQP Not Available'))
      end

    when AM::Actor::MsgExited
      conn = @conns.delete(msg.sender)
      if conn
#        pubsub_unsub_by_actor(msg.sender)
      end

#    when AM::AMQP::Client::MsgDelivery
#      route = @routes[msg.exchange]
#      return if !route
#
#      if route[:handler] == :model
#        payload = JSON.parse(msg.payload)
#
#        obj = nil
#        begin
##          ActiveRecord::Base.connection_pool.with_connection do
#            obj = payload['model'].constantize.find(payload['object_id'])
##          end
#        rescue NameError, ActiveRecord::RecordNotFound
#          obj = nil
#        end

###        @conns.each do |conn|
###          conn.tell(Connection::MsgModelPublish.new(
###            routing_key: msg.routing_key,
###            exchange: msg.exchange,
###            headers: msg.headers,
###            object: obj.freeze,
###            object_type: payload['model'],
###            object_id: payload['object_id'],
###            events: payload['events'],
###            xact_id: payload['xact_id'],
###            person_id: payload['person_id'],
###            credential_id: payload['credential_id'],
###            http_request_id: payload['http_request_id'],
###          ))
###        end
#      else
#        @conns.each do |conn|
#          conn.tell(Connection::MsgDeliver.new(
#            routing_key: msg.routing_key,
#            exchange: msg.exchange,
#            headers: msg.headers,
#            payload: JSON.parse(msg.payload).deep_symbolize_keys,
#          ))
#        end
#      end
#
#      @amqp.tell AM::AMQP::Client::MsgAck.new(channel_id: msg.channel_id, delivery_tag: msg.delivery_tag)
    else
      super
    end
  end

  def actor_crashed!(exception:)
    super

    sleep 1
    exit!(255)
  end
end

end
