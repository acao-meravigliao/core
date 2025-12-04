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
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc
    TinyTds::Client.default_query_options[:timezone] = :utc

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

      config.acao.pics_store = '/opt/pics'

      config.acao.flarmnet_fln_url = 'https://www.flarmnet.org/files/data.fln'
      config.acao.flarmnet_ddb_url = 'https://www.flarmnet.org/files/ddb.json'
      config.acao.ogn_ddb_url = 'https://ddb.glidernet.org/download'
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

      config.rails_vos.object_event_endpoint = 'ygg.model.events'

      config.rails_vos.class_map = [
        'Ygg::Acao::Aircraft',
        'Ygg::Acao::Aircraft::Owner',
        'Ygg::Acao::AircraftSyncStatus',
        'Ygg::Acao::AircraftType',
        'Ygg::Acao::Airfield',
        'Ygg::Acao::BarTransaction',
        'Ygg::Acao::Club',
        'Ygg::Acao::Debt::Detail',
        'Ygg::Acao::Debt',
        'Ygg::Acao::FaiCard',
        'Ygg::Acao::FlarmnetEntry',
        'Ygg::Acao::Flight',
        'Ygg::Acao::Invoice::Detail',
        'Ygg::Acao::Invoice',
        'Ygg::Acao::Year',
        'Ygg::Acao::KeyFob',
        'Ygg::Acao::License',
        'Ygg::Acao::License::Rating',
        'Ygg::Acao::Medical',
        'Ygg::Acao::Member',
        'Ygg::Acao::Member::Role',
        'Ygg::Acao::Membership',
        'Ygg::Acao::MemberService',
        'Ygg::Acao::OgnDdbEntry',
        'Ygg::Acao::OndaInvoiceExport::Detail',
        'Ygg::Acao::OndaInvoiceExport',
        'Ygg::Acao::Payment',
        'Ygg::Acao::RatingType',
        'Ygg::Acao::Role',
        'Ygg::Acao::RosterDay',
        'Ygg::Acao::RosterEntry',
        'Ygg::Acao::SatispayEntity',
        'Ygg::Acao::SatispayProfilePicture',
        'Ygg::Acao::ServiceType',
        'Ygg::Acao::TokenTransaction',
        'Ygg::Acao::WolTarget',
        'Ygg::Core::Location',
        'Ygg::Core::Person::Contact',
        'Ygg::Core::Person::Email',
        'Ygg::Core::Person',
        'Ygg::Core::Session',
        'Ygg::Ml::Address',
        'Ygg::Ml::Address::Validation',
        'Ygg::Ml::Msg',
      ]

      config.rails_vos.routes = {
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

        'ygg.acao.gate.events': {
          type: :topic,
          anonymous_access: true,
          durable: true,
          auto_delete: false,
        },
      }
    end

  end
end
