source 'https://rubygems.org'

#gem 'activerecord', '~> 7.0.0'
#gem 'activemodel', '~> 7.0.0'
#gem 'actionpack', '~> 7.0.0'
#gem 'actionview', '~> 7.0.0'
#gem 'activesupport', '~> 7.0.0'
#gem 'railties', '~> 7.0.0'

gem 'activerecord', '~> 6.1.0'
gem 'activemodel', '~> 6.1.0'
gem 'actionpack', '~> 6.1.0'
gem 'actionview', '~> 6.1.0'
gem 'activesupport', '~> 6.1.0'
gem 'railties', '~> 6.1.0'

gem 'pg'
gem 'tiny_tds'#, '~> 1.1.0'
gem 'activerecord-sqlserver-adapter', '~> 6.1.2.1'
#gem 'activerecord-sqlserver-adapter'#, git: 'https://github.com/rails-sqlserver/activerecord-sqlserver-adapter.git'

gem 'puma'
gem 'puma-plugin-systemd'

#gem 'rbtrace'

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

gem 'airbrake'

source 'https://gems.sevio.it/' do
  gem 'vihai-password', '>= 1.2.0'
  gem 'active_rest', '~> 10.0'#, path: '../active_rest'
  gem 'rails_active_rest', '~> 1.0'#, path: '../rails_active_rest'
  gem 'am-http'
  gem 'json_exceptions'
  gem 'vihai-password-rails'
  gem 'rails_actor_model'
  gem 'rails_amqp'

  gem 'am-smtp'
  gem 'am-satispay'
  gem 'am-ssh'

  group :hel_together do
    #gem 'hel_together', '~> 1.5.2' # For rails 6.0
    gem 'hel_together', '~> 1.6.1' # For rails 6.0
    gem 'nisse_hel', path: '../yggdra/plugins/nisse_hel'
    gem 'core_heltog', path: '../yggdra/plugins/core_heltog'
    gem 'ml_heltog', path: '../yggdra/plugins/ml_heltog'
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
  gem 'hel', path: '../yggdra/plugins/hel'
  gem 'core_hel', path: '../yggdra/plugins/core_hel'
  gem 'i18n_hel', path: '../yggdra/plugins/i18n_hel'
  gem 'ml_hel', path: '../yggdra/plugins/ml_hel'
  gem 'ca_hel', path: '../yggdra/plugins/ca_hel'
  gem 'acao_hel', path: 'plugins/acao_hel'
  #gem 'trk_hel', path: '../acao-plugins/trk_hel'
  gem 'streaming_hel', path: '../yggdra/plugins/streaming_hel'
  gem 'amqp_ws_gw', path: '../yggdra/plugins/amqp_ws_gw'
end

gem 'core_models', path: '../yggdra/plugins/core_models'
gem 'i18n_models', path: '../yggdra/plugins/i18n_models'
gem 'ml_models', path: '../yggdra/plugins/ml_models'
gem 'ca_models', path: '../yggdra/plugins/ca_models'
gem 'acao_maindb_models', path: 'plugins/acao_maindb_models'
gem 'acao_onda_models', path: 'plugins/acao_onda_models'
gem 'acao_models', path: 'plugins/acao_models'
#gem 'trk_models', path: '../acao-plugins/trk_models'
gem 'streaming_models', path: '../yggdra/plugins/streaming_models'

