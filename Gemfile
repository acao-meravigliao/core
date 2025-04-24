source 'https://rubygems.org'

#gem 'activerecord', '~> 7.1.0'
#gem 'activemodel', '~> 7.1.0'
#gem 'actionpack', '~> 7.1.0'
#gem 'actionview', '~> 7.1.0'
#gem 'activesupport', '~> 7.1.0'
#gem 'railties', '~> 7.1.0'
##gem 'sprockets-rails'

gem 'activerecord', '~> 6.1.0'
gem 'activemodel', '~> 6.1.0'
gem 'actionpack', '~> 6.1.0'
gem 'actionview', '~> 6.1.0'
gem 'activesupport', '~> 6.1.0'
gem 'railties', '~> 6.1.0'

gem 'pg'
gem 'tiny_tds'#, '~> 1.1.0'
#gem 'activerecord-sqlserver-adapter', '~> 7.1.0'
gem 'activerecord-sqlserver-adapter', '~> 6.1.2.1'
#gem 'activerecord-sqlserver-adapter'#, git: 'https://github.com/rails-sqlserver/activerecord-sqlserver-adapter.git'

gem 'puma'
gem 'puma-plugin-systemd'

gem 'rbtrace'

gem 'pry'
gem 'pry-rails'
gem 'rb-readline'
gem 'amazing_print'
gem 'geocoder'
gem 'net-ldap'
gem 'mail'
gem 'phone'
gem 'prawn'
gem 'prawn-table'
gem 'matrix'
gem 'concurrent-ruby', '1.3.4'

gem 'airbrake'

source 'https://gems.vihai.it/' do
  gem 'vihai-password', '>= 1.2.0'
  gem 'active_rest', '~> 10.0'#, path: '../active_rest'
  gem 'rails_active_rest', '~> 1.0'#, path: '../rails_active_rest'
  gem 'am-http'
  gem 'json_exceptions'
  gem 'vihai-password-rails'
  gem 'rails_actor_model'
  gem 'rails_amqp', '= 1.0.5'

  gem 'am-smtp'
  gem 'am-satispay'
  gem 'am-ssh'
  gem 'am-ws'
  gem 'ygg-diffable'
  gem 'iarray'

  group :hel_together do
    #gem 'hel_together', '~> 1.5.2' # For rails 6.0
    gem 'hel_together', '~> 1.6.1' # For rails 6.0
    gem 'nisse_hel', path: 'plugins/nisse_hel'
    gem 'core_heltog', path: 'plugins/core_heltog'
    gem 'ml_heltog', path: 'plugins/ml_heltog'
    gem 'acao_heltog', path: 'plugins/acao_heltog'
  end
end

group :hel_development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
#  gem 'web-console', '~> 3.3'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :controllers do
  gem 'hel', path: 'plugins/hel'
  gem 'core_hel', path: 'plugins/core_hel'
  gem 'i18n_hel', path: 'plugins/i18n_hel'
  gem 'ml_hel', path: 'plugins/ml_hel'
  gem 'ca_hel', path: 'plugins/ca_hel'
  gem 'acao_hel', path: 'plugins/acao_hel'
  #gem 'trk_hel', path: '../acao-plugins/trk_hel'
  gem 'streaming_hel', path: 'plugins/streaming_hel'
  gem 'amqp_ws_gw', path: 'plugins/amqp_ws_gw'
  gem 'rails_vos', path: 'plugins/rails_vos'
end

gem 'core_models', path: 'plugins/core_models'
gem 'i18n_models', path: 'plugins/i18n_models'
gem 'ml_models', path: 'plugins/ml_models'
gem 'ca_models', path: 'plugins/ca_models'
gem 'acao_maindb_models', path: 'plugins/acao_maindb_models'
gem 'acao_models', path: 'plugins/acao_models'
#gem 'trk_models', path: '../acao-plugins/trk_models'
gem 'streaming_models', path: 'plugins/streaming_models'

