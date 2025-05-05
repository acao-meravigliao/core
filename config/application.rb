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
  Bundler.require("hel_together_#{Rails.env}")
  Bundler.require('controllers')
elsif File.basename($0) =~ /puma/
  Bundler.require('puma')
  Bundler.require("puma_#{Rails.env}")
  Bundler.require('controllers')
elsif Rails.env == 'development' || Rails.env == 'test'
  Bundler.require('controllers')
end

require 'socket'

module AcaoCore
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2
    config.active_record.schema_format = :sql

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.action_controller.default_protect_from_forgery = false

    config.app_version = /releases\/([0-9]+)/.match(File.expand_path(__dir__)) ? "rel-#{$1}" : (
                           `git describe --tags --dirty --long` || `git rev-parse HEAD`).chop

    config.ml.default_sender = 'INFO_ACAO'

    Geocoder.configure(
      google: {
        api_key: Rails.application.credentials.geocoder_api_key,
        use_https: true,
        bounds: [[46.529301, 6.563564], [36.827650,18.626552]],
        language: 'it',
      }
    )

    if config.respond_to?(:acao)
      config.acao.satispay_callback_url = 'https://servizi.acao.it/ygg/acao/payments/satispay_callback'

      config.acao.wol_key_path = '/opt/lino-wol'
      config.acao.wol_username = 'lino-wol'
      config.acao.wol_host = 'rutterone.acao.it'
    end

    if config.respond_to?(:rails_vos)
      config.rails_vos.debug = 2
      config.rails_vos.authentication_needed = false

      config.rails_vos.shared_queue = {
        name: 'ygg.acao_core.' + Socket.gethostname,
        durable: false,
        auto_delete: true,
        arguments: {
          'x-message-ttl': 30000,
        },
      }

      config.rails_vos.routes = {
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
    end

    if config.respond_to?(:amqp_ws_gw)
      config.amqp_ws_gw.debug = 2
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
    end
  end
end
