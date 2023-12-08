#
# Copyright (C) 2016-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'actor_model'
require 'deep_open_struct'

module Ygg
module AmqpWsGw

class Gateway
  include AM::Actor

  class Ref < AM::ActorRef
    def get_connections
      ask(MsgGetConnections.new).value
    end
  end

  self.actor_ref_class = Ref

  class Connection
    attr_accessor :ref
    attr_accessor :session_id
    attr_accessor :remote_addr
    attr_accessor :remote_port

    def initialize(**args)
      args.each { |k,v| send("#{k}=", v) }
    end

    def as_json
     {
      session_id: session_id,
      remote_addr: remote_addr,
      remote_port: remote_port,
     }
    end
  end

  class MsgRegisterConnection < AM::Msg
    attr_accessor :session_id
    attr_accessor :remote_addr
    attr_accessor :remote_port
  end
  class MsgRegisterConnectionOk < AM::Msg
    attr_accessor :online
    attr_accessor :offline_reason
  end

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

  class MsgSubscribe < AM::Msg
    attr_accessor :exchange_name
  end

  class MsgUnsubscribe < AM::Msg
    attr_accessor :exchange_name
  end

  def initialize(routes_config:)
    @routes_config = DeepOpenStruct.new(routes_config)

    actor_initialize(actor_id: :amqp_gateway)
  end

  def actor_boot
    @connections = {}

    @routes = {}
    @queues = {}

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

      Airbrake[:default].notify("Permanent failure while initializing AMPQ: #{e}") do |notice|
        notice[:context][:component] = self.class.name
        notice[:context][:severity] = 'critical'
      end

      @online = false
      return
    end

    @online = true
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
    case msg
    when MsgRegisterConnection
      @connections[msg.sender] = Connection.new(
        ref: msg.sender,
        session_id: msg.session_id,
        remote_addr: msg.remote_addr,
        remote_port: msg.remote_port,
      )

      actor_tell msg.sender, MsgMonitor.new
      actor_reply msg, MsgRegisterConnectionOk.new(online: @online, offline_reason: @offline_reason)

    when MsgGetConnections
      @connections[msg.sender] = msg.sender
      actor_reply msg, MsgGetConnectionsReply.new(connections: Hash[@connections.map { |k,v| [ k.id, v.as_json ] }])

    when MsgSubscribe
      route = @routes[msg.exchange_name]
      return if !route

      if route[:refcount] == 0
        @amqp.ask(AM::AMQP::Client::MsgQueueBind.new(channel_id: @amqp_chan, queue_name: route[:queue],
                      exchange_name: route[:exchange], routing_key: route[:routing_key])).value
      end

      route[:refcount] += 1

    when MsgUnsubscribe
      route = @routes[msg.exchange_name]
      return if !route

      if route[:refcount] > 0
        route[:refcount] -= 1

        if route[:refcount] == 0
          @amqp.ask(AM::AMQP::Client::MsgQueueUnbind.new(channel_id: @amqp_chan, queue_name: route[:queue],
                        exchange_name: route[:exchange], routing_key: route[:routing_key])).value
        end
      end

    when AM::AMQP::Client::MsgQueueBindFailure
      log.error "Bind failure: #{msg}"

    when AM::AMQP::Client::MsgQueueUnbindFailure
      log.error "Unbind failure: #{msg}"

    when AM::AMQP::Client::MsgOperationalStateChange
      if msg.state == :bad
        @online = false
      else
        @online = true
      end
      @connections.keys.each do |conn|
        conn.tell(WsConnection::MsgSetOnline.new(online: @online, offline_reason: 'AMQP Not Available'))
      end

    when AM::Actor::MsgExited
      @connections.delete(msg.sender)

    when AM::AMQP::Client::MsgDelivery
      route = @routes[msg.exchange]
      return if !route

      if route[:handler] == :model
        payload = JSON.parse(msg.payload)

        obj = nil
        begin
#          ActiveRecord::Base.connection_pool.with_connection do
            obj = payload['model'].constantize.find(payload['object_id'])
#          end
        rescue NameError, ActiveRecord::RecordNotFound
          obj = nil
        end

        @connections.keys.each do |conn|
          conn.tell(Ygg::AmqpWsGw::WsConnection::MsgModelPublish.new(
            routing_key: msg.routing_key,
            exchange: msg.exchange,
            headers: msg.headers,
            object: obj.freeze,
            object_type: payload['model'],
            object_id: payload['object_id'],
            events: payload['events'],
            xact_id: payload['xact_id'],
            person_id: payload['person_id'],
            credential_id: payload['credential_id'],
            http_request_id: payload['http_request_id'],
          ))
        end
      else
        @connections.keys.each do |conn|
          conn.tell(Ygg::AmqpWsGw::WsConnection::MsgPublish.new(
            routing_key: msg.routing_key,
            exchange: msg.exchange,
            headers: msg.headers,
            payload: JSON.parse(msg.payload).deep_symbolize_keys,
          ))
        end
      end

      @amqp.tell AM::AMQP::Client::MsgAck.new(channel_id: msg.channel_id, delivery_tag: msg.delivery_tag)
    else
      super
    end
  end

  def actor_crashed!(exception:)
    super

    exit!(255)
  end
end

end
end
