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

  config.rails_amqp.url = 'amqp://agent@linobis.acao.it'
  config.rails_amqp.debug = 0

  config.ml.email_disabled = false
  config.ml.email_redirect_to = 'daniele@orlandi.com'
  config.ml.sms_disabled = true
  config.ml.sms_redirect_to = '+393474659309'
  config.ml.sms_skebby_debug = 0

  if config.respond_to?(:amqp_ws_gw)
    config.amqp_ws_gw.allowed_request_origins = [
      'https://linobis.acao.it',
      'http://linobis.acao.it:4200',
      'https://dashboard-linobis.acao.it',
    ]

    config.amqp_ws_gw.routes.merge!({
      'ygg.glideradar.processed_traffic': {
        type: :topic,
        durable: true,
        auto_delete: false,
        anonymous_access: true,
      },
      'ygg.glideradar.processed_traffic.linobis': {
        type: :topic,
        durable: true,
        auto_delete: false,
        anonymous_access: true,
      },
    })
  end

  config.acao.soci_ml_dry_run = true
end
