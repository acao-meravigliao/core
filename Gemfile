source 'https://rubygems.org'

gem 'activerecord', '~> 8.1'
gem 'activemodel', '~> 8.1'
gem 'actionpack', '~> 8.1'
gem 'actionview', '~> 8.1'
gem 'activesupport', '~> 8.1'
gem 'railties', '~> 8.1'

gem 'pg'
gem 'tiny_tds'
gem 'activerecord-sqlserver-adapter', '~> 8.1'

gem 'puma'

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
gem 'mime-types'
gem 'rszr'

gem 'airbrake'

source 'https://gems.vihai.it/' do
  gem 'vihai-password', '>= 1.2.0'
  gem 'active_rest', '~> 10.0'#, path: '../active_rest'
  gem 'rails_active_rest', '~> 1.0'#, path: '../rails_active_rest'
  gem 'json_exceptions'
  gem 'vihai-password-rails'
  gem 'rails_actor_model'
  gem 'rails_amqp'

  gem 'am-http'
  gem 'am-smtp'
  gem 'am-satispay', '>= 0.2.0'
  gem 'am-ssh'
  gem 'am-ws'
  gem 'am-vos', '>= 3'
  gem 'am-auth-manager'
  gem 'ygg-diffable'
  gem 'iarray'

  group :hel_together do
    gem 'hel_together', '~> 2.0'
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
  gem 'streaming_hel', path: 'plugins/streaming_hel'
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

