source 'https://rubygems.org'

gem 'rails', '~> 5.1.0'

gem 'pg'
gem 'tiny_tds'#, '~> 1.1.0'
gem 'activerecord-sqlserver-adapter', git: 'https://github.com/rails-sqlserver/activerecord-sqlserver-adapter.git'

gem 'puma'

source 'https://gems.sevio.it/' do
  gem 'puma-plugin-systemd'
end

gem 'pry'
gem 'pry-rails'
gem 'awesome_print'
#gem 'state_machine'
gem 'geocoder'
gem 'net-ldap'
gem 'mail'
gem 'phone'

gem 'airbrake'

source 'https://gems.sevio.it/' do
  gem 'vihai-password', '>= 1.2.0'
  gem 'active_rest', '~> 7.0.0', path: '../active_rest'
  gem 'am-http'
end

group :hel_development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
#  gem 'web-console', '~> 3.3'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :hel_together do
  gem 'hel_together', '~> 1.3.0'
  gem 'nisse_hel', path: '../yggdra/plugins/nisse_hel'
  gem 'core_nisse_hel', path: '../yggdra/plugins/core_nisse_hel'
  gem 'ml_heltog', path: '../yggdra/plugins/ml_heltog'
end

gem 'json_exceptions', path: '../yggdra/plugins/json_exceptions'
gem 'vihai-password-rails', path: '../yggdra/plugins/vihai_password_rails'

gem 'hel', path: '../yggdra/plugins/hel'

gem 'rails_actor_model', path: '../yggdra/plugins/rails_actor_model'
gem 'rails_amqp', path: '../yggdra/plugins/rails_amqp'
gem 'amqp_ws_gw', path: '../yggdra/plugins/amqp_ws_gw'

gem 'core_models', path: '../yggdra/plugins/core_models'
gem 'core_hel', path: '../yggdra/plugins/core_hel'

gem 'i18n_models', path: '../yggdra/plugins/i18n_models'
gem 'i18n_hel', path: '../yggdra/plugins/i18n_hel'

gem 'ml_models', path: '../yggdra/plugins/ml_models'
gem 'ml_hel', path: '../yggdra/plugins/ml_hel'

gem 'ca_models', path: '../yggdra/plugins/ca_models'
gem 'ca_hel', path: '../yggdra/plugins/ca_hel'

#gem 'shop_models', path: '../yggdra/plugins/shop_models'
#gem 'shop_hel', path: '../yggdra/plugins/shop_hel'

gem 'acao_maindb_models', path: '../acao_plugins/acao_maindb_models'
gem 'acao_onda_models', path: '../acao_plugins/acao_onda_models'
gem 'acao_models', path: '../acao_plugins/acao_models'
gem 'acao_hel', path: '../acao_plugins/acao_hel'

gem 'trk_models', path: '../acao_plugins/trk_models'
gem 'trk_hel', path: '../acao_plugins/trk_hel'

gem 'streaming_models', path: '../yggdra/plugins/streaming_models'
gem 'streaming_hel', path: '../yggdra/plugins/streaming_hel'
