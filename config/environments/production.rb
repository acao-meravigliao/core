require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true
  config.enable_reloading = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from `public/`, relying on NGINX/Apache to do so instead.
  # config.public_file_server.enabled = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # Can be used together with config.force_ssl for Strict-Transport-Security and secure cookies.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT by default
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # "info" includes generic and useful information about system operation, but avoids logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII). If you
  # want to log everything, set the level to "debug".
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

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
