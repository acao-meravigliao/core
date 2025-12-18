bind 'tcp://[::]:3000'

directory '/opt/acao-core/current'

threads 8,32
workers 3
preload_app!

state_path 'log/puma-production.state'
pidfile 'log/puma-production.pid'

plugin :systemd

on_worker_boot do
  RailsActorModel::Logger.new

  RailsVos.start

  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end

#require 'rbtrace'
