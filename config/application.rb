require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'

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

require 'socket'

module AcaoCore
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.app_version = /releases\/([0-9]+)/.match(File.expand_path(__dir__)) ? "rel-#{$1}" : (
                           `git describe --tags --dirty --long` || `git rev-parse HEAD`).chop

    config.amqp_ws_gw.debug = 1

    config.ml.default_sender = 'INFO_ACAO'

    Geocoder.configure(
      google: {
        api_key: Rails.application.secrets.geocoder_api_key,
        use_https: true,
        bounds: [[46.529301, 6.563564], [36.827650,18.626552]],
        language: 'it',
      }
    )

    config.amqp_ws_gw.authentication_needed = false

    config.amqp_ws_gw.shared_queue = {
      name: 'ygg.acao_core.' + Socket.gethostname,
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

      'ygg.meteo.updates': {
        type: :topic,
        anonymous_access: true,
        durable: true,
        auto_delete: false,
      },
    }

    config.acao.satispay_callback_url = 'https://servizi.acao.it/ygg/acao/payments/satispay_callback'
  end
end
