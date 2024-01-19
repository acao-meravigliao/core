Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.rails_amqp.url = 'amqp://agent@amqp.acao.it'
  config.rails_amqp.debug = 0

  #config.ml.email_also_bcc = 'daniele@orlandi.com'

  config.acao.soci_ml_dry_run = false
  config.acao.faac_endpoint = 'https://ac-controller.acao.it/'
  config.acao.faac_generic_user = 'acao'
  config.acao.faac_debug = 0
  config.acao.faac_actions = {
    CANCELLO: '3870651b-3702-454c-ad30-42c16337ebbf',
    SBARRA: 'e4113bd9-c6b9-401b-a157-2c37b83b5155',
    PEDONALE: 'a93e70a7-0e62-48bb-82be-5d6c769cb6a4',
  }

  if config.respond_to?(:rails_vos)
    config.rails_vos.allowed_request_origins = [
      'https://lino.acao.it',
      'https://servizi.acao.it',
      'https://servizi-lilc.acao.it',
      'https://servizi-staging.acao.it',
      'https://pub.acao.it',
      'https://dash.acao.it',
    ]

    config.rails_vos.routes.merge!({
      'ygg.glideradar.processed_traffic.live': {
        type: :topic,
        durable: true,
        auto_delete: false,
        anonymous_access: true,
      },
      'ygg.autocam.state': {
        type: :topic,
        durable: true,
        auto_delete: false,
        anonymous_access: true,
      },
    })
  end

  if config.respond_to?(:amqp_ws_gw)
    config.amqp_ws_gw.allowed_request_origins = [
      'https://lino.acao.it',
      'https://servizi.acao.it',
      'https://servizi-lilc.acao.it',
      'https://servizi-staging.acao.it',
      'https://pub.acao.it',
      'https://dash.acao.it',
    ]

    config.amqp_ws_gw.routes.merge!({
      'ygg.glideradar.processed_traffic.live': {
        type: :topic,
        durable: true,
        auto_delete: false,
        anonymous_access: true,
      },
      'ygg.autocam.state': {
        type: :topic,
        durable: true,
        auto_delete: false,
        anonymous_access: true,
      },
    })
  end
end
