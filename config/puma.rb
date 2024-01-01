bind 'tcp://[::]:3330'

threads 1,8
workers 1
preload_app!

quiet false

state_path 'log/puma.state'
pidfile 'log/puma.pid'

on_worker_boot do
  begin
    require 'rails_actor_model/logger'
    RailsActorModel::Logger.new

    RailsVos.start
    Ygg::AmqpWsGw.start

    ActiveSupport.on_load(:active_record) do
      ActiveRecord::Base.establish_connection
    end

  rescue Exception => e
    puts "Exception in on_worker_boot: #{e}"
    puts e.backtrace.join("\n")
  end
end
