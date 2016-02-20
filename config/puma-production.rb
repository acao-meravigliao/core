bind 'tcp://[::]:3000'

threads 8,32
workers 3
preload_app!

state_path 'log/puma-production.state'
pidfile 'log/puma-production.pid'

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end

  Ygg::Core::Amqp.interface_init
end
