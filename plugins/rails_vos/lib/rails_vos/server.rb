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

require 'am/vos/server'
require 'am/auth_manager'

module Vos
end

module RailsVos

class AuthManager
  include AM::Actor

  def actor_handle(msg)
    case msg
    when AM::AuthManager::MsgSessionGet

      session = nil

      ActiveRecord::Base.connection_pool.with_connection do
        session = Ygg::Core::Session.find_by(id: msg.id)
      end

      if !session
        actor_reply msg, AM::AuthManager::MsgSessionGetNotFound.new
        return
      end

      actor_reply(msg, AM::AuthManager::MsgSessionGetOk.new(
        id: msg.id,
        authenticated: session.authenticated?,
        data: session.data,
      ))

    when AM::AuthManager::MsgSessionSet
    when AM::AuthManager::MsgSessionDel
    when AM::AuthManager::MsgSessionAuth
    else
     super
    end
  end
end

class ClassMap
  class Entry
    attr_accessor :vos_name
    attr_accessor :ar_class
    attr_accessor :gs_class
  end

  def initialize(definitions:)
    @by_vos_name = {}
    @by_ar_class = {}
    @by_gs_class = {}

    definitions.sort_by(&:length).each do |df|
      entry = Entry.new

      entry.vos_name = class_name_to_jsonapi(df)
      entry.ar_class = Object.const_get(df)

      comps = entry.ar_class.name.split('::')
      lastmod = comps[0..-2].reduce(::Vos) { |a,x| a.const_defined?(x, false) ? a.const_get(x, false) :  a.const_set(x, Module.new) }

      if lastmod.const_defined?(comps.last, false)
        entry.gs_class = lastmod.const_get(comps.last, false)
      else
        entry.gs_class = Class.new(GrafoStore::Obj) do
          entry.ar_class.attribute_names.each do |attr|
            gs_attr_accessor attr if attr != 'id'
          end

          define_singleton_method :ar_class do
            entry.ar_class
          end
        end

        entry.ar_class.define_singleton_method :gs_class do
          entry.gs_class
        end

        lastmod.const_set(comps.last, entry.gs_class)
      end

      @by_vos_name[entry.vos_name] = entry
      @by_ar_class[entry.ar_class] = entry
      @by_gs_class[entry.gs_class] = entry
    end

  end

  def by_gs_class(cls)
    @by_gs_class[cls]
  end

  def by_ar_class(cls)
    @by_ar_class[cls]
  end

  def by_vos_name(vos_name)
    @by_vos_name[vos_name]
  end

  def jsonapi_to_class_name(str)
    str = str.to_s
    str.gsub!(/--/, '/')
    str.gsub!(/-/, '_')
    str.camelize
  end

  def class_name_to_jsonapi(str)
    str = str.to_s.underscore
    str.gsub!(/^\//, '')
    str.gsub!(/\//, '--')
    str.gsub!(/_/, '-')
    str
  end
end

class Server
  include AM::Actor

  attr_reader :instance_id

  def initialize(routes_config:, class_map:)
    @routes_config = DeepOpenStruct.new(routes_config)
    @class_map = class_map

    super(actor_id: :rails_vos_server)
  end

  def actor_boot
    @instance_id = SecureRandom.uuid

    @conns = []

#    @routes = {}
#    @queues = {}

    @auth_manager = AuthManager.new()

    @ds = actor_supervise_new(AM::GrafoStore::Store, config: {
      actor_id: :ds,
      store_class: ::Ygg::Core::SqlGrafoStore,
      grafo_events_to: actor_ref,
      debug: 2,
    }, shut_order: 1000)

    @vos = actor_supervise_new(AM::VOS::Server, config: {
      actor_id: :vos,
      class_map: @class_map,
      welcome_extra_params: {
        app_version: '0.0.0',
        server_identifier: Rails.application.class.module_parent_name,
      },
      ds: @ds,
      auth_manager: @auth_manager,
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
      log.fatal "Permanent failure while initializing AMPQ: #{e.backtrace}"

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

    queue_name = @amqp.ask(AM::AMQP::Client::MsgQueueDeclare.new(
      channel_id: @amqp_chan,
      name: "#{Rails.application.config.rails_vos.object_event_endpoint}.#{Process.pid}",
      passive: false,
      durable: false,
      exclusive: true,
      auto_delete: true,
      arguments: {},
    )).value.name

    @amqp.ask(AM::AMQP::Client::MsgExchangeDeclare.new(
      channel_id: @amqp_chan,
      name: Rails.application.config.rails_vos.object_event_endpoint,
      type: :topic,
      passive: false,
      durable: true,
      auto_delete: false,
      internal: false,
      arguments: {},
    )).value

    @amqp.ask(AM::AMQP::Client::MsgQueueBind.new(
      channel_id: @amqp_chan,
      queue_name: queue_name,
      exchange_name: Rails.application.config.rails_vos.object_event_endpoint,
      routing_key: '#',
    )).value

    consumer_tag  = @amqp.ask(AM::AMQP::Client::MsgConsume.new(
      channel_id: @amqp_chan,
      queue_name: queue_name,
      send_to: actor_ref)
    ).value.consumer_tag



#    @routes_config.each do |ex_name, ex|
#      if ex.queue && !@queues[ex.queue.name]
#        queue_name = @amqp.ask(AM::AMQP::Client::MsgQueueDeclare.new(
#          channel_id: @amqp_chan,
#          name: "#{ex.queue.name}.#{Process.pid}",
#          passive: ex.queue.passive || false,
#          durable: ex.queue.durable || false,
#          exclusive: ex.queue.exclusive || true,
#          auto_delete: ex.queue.auto_delete || true,
#          arguments: ex.queue.arguments.to_h || {},
#        )).value.name
#
#        @queues[queue_name] = true
#      end
#
#      @amqp.ask(AM::AMQP::Client::MsgExchangeDeclare.new(
#        channel_id: @amqp_chan,
#        name: ex_name.to_s,
#        type: ex.type || :topic,
#        passive: ex.passive || false,
#        durable: ex.durable || true,
#        auto_delete: ex.auto_delete || false,
#        internal: ex.internal || false,
#        arguments: ex.arguments.to_h || {},
#      )).value
#
#      consumer_tag  = @amqp.ask(AM::AMQP::Client::MsgConsume.new(
#        channel_id: @amqp_chan,
#        queue_name: queue_name,
#        send_to: actor_ref)
#      ).value.consumer_tag
#
#      @routes[ex_name.to_s] = {
#        queue: queue_name,
#        exchange: ex_name.to_s,
#        handler: ex.handler,
#        consumer_tag: consumer_tag,
#        routing_key: ex.routing_key || '#',
#        refcount: 0,
#      }
#    end
  end

  class ControllerNotFound < Ygg::Exception ; end
  class MethodNotFound < Ygg::Exception ; end
  class AAAContextNotFoundError < Ygg::Exception ; end

  def actor_handle(msg)
    case msg
    when AM::VOS::Server::MsgClassCall

      session = Ygg::Core::Session.find_by(id: msg.session_id)
      if !session
        actor_reply(msg, AM::VOS::Server::MsgCallFail.new(cause: AAAContextNotFoundError.new))
        return
      end

      ctr_cls = nil
      begin
        ctr_cls = msg.cls.ar_class.const_get('VosController', false)
      rescue NameError
        actor_reply(msg, AM::VOS::Server::MsgCallFail.new(cause: ControllerNotFound.new))
        return
      end

      ctr = ctr_cls.new(
        vos_server: self,
        ds: @ds,
        session: session,
        request_id: msg.request_id,
      )

      meth = nil
      begin
        meth = ctr.method(msg.method)
      rescue NameError
        actor_reply(msg, AM::VOS::Server::MsgCallFail.new(cause: MethodNotFound.new))
        return
      end

      begin
        body = meth.call(body: msg.body, **(msg.params || {}))
      rescue StandardError => e
        actor_reply(msg, AM::VOS::Server::MsgCallFail.new(cause: e))

        log.error "Call error: #{e}"
        log.error e.backtrace
      else
        actor_reply(msg, AM::VOS::Server::MsgCallOk.new(body: body))
      end

    when AM::VOS::Server::MsgCall
      session = Ygg::Core::Session.find_by(id: msg.session_id)
      if !session
        actor_reply(msg, AM::VOS::Server::MsgCallFail.new(cause: AAAContextNotFoundError.new))
        return
      end

      ctr_cls = nil
      begin
        ctr_cls = msg.obj.class.ar_class.const_get('VosController', false)
      rescue NameError
        actor_reply(msg, AM::VOS::Server::MsgCallFail.new(cause: ControllerNotFound.new))
        return
      end

      ctr = ctr_cls.new(
        vos_server: self,
        ds: @ds,
        session: session,
        request_id: msg.request_id,
      )

      meth = nil
      begin
        meth = ctr.method(msg.method)
      rescue NameError
        actor_reply(msg, AM::VOS::Server::MsgCallFail.new(cause: MethodNotFound.new))
        return
      end

      ar_obj = msg.obj.class.ar_class.find(msg.obj.id)

      begin
        body = meth.call(obj: ar_obj, gs_obj: msg.obj, body: msg.body, **(msg.params || {}))
      rescue StandardError => e
        actor_reply(msg, AM::VOS::Server::MsgCallFail.new(cause: e))

        log.error "Call error: #{e}"
        log.error e.backtrace
      else
        actor_reply(msg, AM::VOS::Server::MsgCallOk.new(body: body))
      end

    when AM::HTTP::Server::MsgRequest
      actor_redirect(msg, @vos)

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

    when AM::GrafoStore::Store::MsgTransactionBegin
      puts "TRANSACTION BEGIN"

      if @xact
        raise 'Overlapping transaction???'
      end

      @xact = []

    when AM::GrafoStore::Store::MsgObjectCreated,
         AM::GrafoStore::Store::MsgObjectUpdated,
         AM::GrafoStore::Store::MsgObjectDestroyed,
         AM::GrafoStore::Store::MsgRelationCreated,
         AM::GrafoStore::Store::MsgRelationDestroyed
      @xact << msg

    when AM::GrafoStore::Store::MsgTransactionCommit
      puts "TRANSACTION COMMIT"

      ar_objs = {}
      ar_objs_to_save = Set.new

      Ygg::Core::Transaction.new('Web Operation') do
        @xact.each do |xm|
          case xm
          when AM::GrafoStore::Store::MsgObjectCreated
            puts "OBJ CREATED #{xm.obj.id}"

            ar_obj = xm.obj.class.ar_class.new(id: xm.obj.id, **xm.obj.attrs_hash)
            ar_objs[xm.obj.id] = ar_obj
            ar_objs_to_save << ar_obj

          when AM::GrafoStore::Store::MsgObjectUpdated
            puts "OBJ UPDATED #{xm.obj.id}"

            ar_obj = ar_objs[xm.obj.id] || xm.obj.class.ar_class.find_by(id: xm.obj.id)
            if ar_obj
              ar_obj.attributes = xm.obj.attrs_hash
              ar_objs[xm.obj.id] = ar_obj
              ar_objs_to_save << ar_obj
            end

          when AM::GrafoStore::Store::MsgObjectDestroyed
            puts "OBJ DESTROYED #{xm.obj.id}"

            ar_obj = ar_objs[xm.obj.id] || xm.obj.class.ar_class.find_by(id: xm.obj.id)
            if ar_obj
              ar_objs_to_save.delete(ar_obj)
              ar_obj.destroy
            end

          when AM::GrafoStore::Store::MsgRelationCreated
            puts "REL CREATED #{xm.rel}"

            ar_obj_a = ar_objs[xm.rel.a] ||= xm.a.class.ar_class.find(xm.rel.a)
            ar_obj_b = ar_objs[xm.rel.b] ||= xm.b.class.ar_class.find(xm.rel.b)

            [ ar_obj_a, ar_obj_b ].compact.each do |ar_obj|
              # We should now search into gs_rel_map(s) to find if this relation matches any of them

              reldef = ar_obj.class.gs_rel_map.find { |x|
                xm.rel.match?(a: ar_obj.id, a_as: x[:from], b_as: x[:to])
              }

              if reldef
                if reldef[:from_key]
                  ar_obj.send("#{reldef[:from_key]}=", xm.rel.orient(a_as: reldef[:from]).b)
                  ar_objs_to_save << ar_obj
                  break
                else
                  fk = xm.rel.orient(b_as: reldef[:to]).b
                  oth_model = ar_objs[fk] ||= reldef[:to_cls].constantize.find(fk)
                  oth_model.send("#{reldef[:to_key]}=", xm.rel.orient(a_as: reldef[:from]).a);
                  ar_objs_to_save << oth_model
                  break
                end
              end
            end

          when AM::GrafoStore::Store::MsgRelationDestroyed
            puts "REL DESTROYED #{xm.rel}"

            # Take relation endpoint objects from cache

            ar_obj_a = ar_objs[xm.rel.a] ||= xm.a.class.ar_class.find(xm.rel.a)
            ar_obj_b = ar_objs[xm.rel.b] ||= xm.b.class.ar_class.find(xm.rel.b)

            [ ar_obj_a, ar_obj_b ].compact.each do |ar_obj|
              # We should now search into gs_rel_map(s) to find if this relation matches any of them

              reldef = ar_obj.class.gs_rel_map.find { |x|
                xm.rel.match?(a: ar_obj.id, a_as: x[:from], b_as: x[:to])
              }

              if reldef
                if reldef[:from_key]
                  ar_obj.send("#{reldef[:from_key]}=", nil)
                  ar_objs_to_save << ar_obj
                  break
                else
                  fk = xm.rel.orient(b_as: reldef[:to]).b
                  oth_model = ar_objs[fk] ||= reldef[:to_cls].constantize.find(fk)
                  oth_model.send("#{reldef[:to_key]}=", nil);
                  ar_objs_to_save << oth_model
                  break
                end
              end
            end
          end
        end

        ar_objs_to_save.each do |obj|
          obj.save!
        end
      end

      @xact = nil

    when AM::Actor::MsgExited
      conn = @conns.delete(msg.sender)
      if conn
#        pubsub_unsub_by_actor(msg.sender)
      end

    when AM::AMQP::Client::MsgDelivery

puts "DELIVERY #{msg}"

      case msg.headers[:type]
      when 'LIFECYCLE_UPDATE'
        payload = JSON.parse(msg.payload, symbolize_names: true)

        if payload[:store_id] != @instance_id
          events = payload[:events]

          if events.include?('C')
            obj = Object.const_get(payload[:model], false).find_by(id: payload[:object_id])
            if obj
              gs_obj = obj.class.gs_class.new(**obj.attributes)

              @ds.tell(::AM::GrafoStore::Store::MsgObjectCreate.new(
                obj: gs_obj,
                from_backend: true,
                quiet: true,
              ))
            end

            # XXX TODO implement relations

          elsif events.include?('U')
            obj = Object.const_get(payload[:model], false).find_by(id: payload[:object_id])
            if obj
              attrs = obj.attributes
              attrs.symbolize_keys!
              attrs.delete(:id)

              @ds.tell(::AM::GrafoStore::Store::MsgObjectUpdate.new(
                id: obj.id,
                vals: attrs,
                from_backend: true,
                quiet: true,
              ))
            end

            # XXX TODO implement relations

          elsif events.include?('D')
            obj = Object.const_get(payload[:model], false).find_by(id: payload[:object_id])
            if obj
              @ds.tell(::AM::GrafoStore::Store::MsgObjectDestroy.new(
                id: obj.id,
                from_backend: true,
                quiet: true,
              ))
            end
          end
        end
      end

      @amqp.tell AM::AMQP::Client::MsgAck.new(channel_id: msg.channel_id, delivery_tag: msg.delivery_tag)

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
