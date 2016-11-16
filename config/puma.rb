bind 'tcp://[::]:3330'

threads 2,8
workers 2
preload_app!

state_path 'log/puma.state'
pidfile 'log/puma.pid'

on_worker_boot do
  Ygg::AmqpWsGw.start

  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
