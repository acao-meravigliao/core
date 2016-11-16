require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'ygg/i18n/backend'
I18n.backend = Ygg::I18n::Backend.new

module AcaoDashboardBackend
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.assets.paths << File.join(Rails.root, 'app', 'assets', 'js')
    config.assets.paths << File.join(Rails.root, 'app', 'assets', 'css')

    config.amqp_ws_gw.allowed_request_origins = [
      'http://dev.yggdra.it:3000',
      'http://dev.yggdra.it:3001',
      'http://62.212.12.194:3001',
    ]

    config.rails_amqp.url = 'amqp://agent@lino.acao.it'
    config.rails_amqp.debug = 0

    config.amqp_ws_gw.routes = {
      'ygg.model.events': {
        handler: :model,
        exchange_type: :topic,
        exchange_options: {
          durable: true,
          auto_delete: false,
        },
        queue_name: 'ygg.hel.model.events.dev',
        queue_options: {
          durable: true,
          auto_delete: false,
        },
      },
      'ygg.asgard.wall': {
        exchange_type: :topic,
        exchange_options: {
          durable: true,
          auto_delete: false,
        },
        queue_name: 'ygg.hel.asgard.wall.dev',
        queue_options: {
          durable: true,
          auto_delete: false,
        },
      },

      'ygg.glideradar.processed_traffic': {
        exchange_type: :topic,
        exchange_options: {
          durable: true,
          auto_delete: false,
        },
        routing_key: '#',
        queue_name: 'ygg.fayeway.bis.glideradar.processed_traffic',
        queue_options: {
          durable: false,
          auto_delete: true,
          arguments: {
            'x-message-ttl': 30000,
          },
        },
      },

      'glideradar.events': {
        exchange_type: :topic,
        exchange_options: {
          durable: true,
          auto_delete: false,
        },
        routing_key: '#',
        queue_name: 'ygg.fayeway.bis.glideradar.events',
        queue_options: {
          durable: false,
          auto_delete: true,
          arguments: {
            'x-message-ttl': 30000,
          },
        },
      },

      'ygg.meteo.updates': {
        exchange_type: :topic,
        exchange_options: {
          durable: true,
          auto_delete: false,
        },
        routing_key: '#',
        queue_name: 'ygg.fayeway.bis.meteo.updates',
        queue_options: {
          durable: false,
          auto_delete: true,
          arguments: {
            'x-message-ttl': 30000,
          },
        },
      },
    }

  end
end
