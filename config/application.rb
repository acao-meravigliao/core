require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if ENV['HEL_TOGETHER_VERSION']
  Bundler.require('hel_together')
  Bundler.require('hel_together_' + Rails.env)
else
  Bundler.require('hel')
  Bundler.require('hel_' + Rails.env)
end

require 'ygg/i18n/backend'
I18n.backend = Ygg::I18n::Backend.new

require 'socket'

module AcaoDashboardBackend
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.assets.paths << File.join(Rails.root, 'app', 'assets', 'js')
    config.assets.paths << File.join(Rails.root, 'app', 'assets', 'css')

    config.amqp_ws_gw.debug = 1
    config.amqp_ws_gw.allowed_request_origins = [
      'http://dev.yggdra.it:3000',
      'http://dev.yggdra.it:3001',
      'http://62.212.12.194:3001',
    ]

    config.rails_amqp.url = 'amqp://agent@lino.acao.it'
    config.rails_amqp.debug = 0

    config.amqp_ws_gw.shared_queue = {
      name: 'ygg.acao_dashboard.' + Socket.gethostname,
      durable: false,
      auto_delete: true,
      arguments: {
        'x-message-ttl': 30000,
      },
    }

    config.amqp_ws_gw.routes = {
      'ygg.model.events': {
        handler: :model,
        type: :topic,
        durable: true,
        auto_delete: false,
      },
      'ygg.asgard.wall': {
        type: :topic,
        durable: true,
        auto_delete: false,
      },

      'glideradar.events': {
        type: :topic,
        durable: true,
        auto_delete: false,
      },

      'ygg.meteo.updates': {
        type: :topic,
        anonymous_acces: true,
        durable: true,
        auto_delete: false,
      },
    }

  end
end
