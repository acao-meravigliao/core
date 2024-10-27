require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Enable server timing.
  config.server_timing = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  config.hosts.clear
  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true


  config.rails_amqp.url = 'amqp://agent@linobis.acao.it'
  config.rails_amqp.debug = 1

  config.ml.email_disabled = false
  config.ml.email_redirect_to = 'daniele@orlandi.com'
  config.ml.sms_disabled = true
  config.ml.sms_redirect_to = '+393474659309'
  config.ml.sms_skebby_debug = 2
  config.ml.mailman_sync_disabled = true

  config.acao.soci_ml_dry_run = true

  config.acao.faac_dry_run = true
  config.acao.faac_endpoint = 'https://ac-controller.acao.it/'
  config.acao.faac_generic_user = 'acao'
  config.acao.faac_debug = 2
  config.acao.faac_actions = {
    CANCELLO: '3870651b-3702-454c-ad30-42c16337ebbf',
    SBARRA: 'e4113bd9-c6b9-401b-a157-2c37b83b5155',
    PEDONALE: 'a93e70a7-0e62-48bb-82be-5d6c769cb6a4',
  }

  config.acao.wp_sync_disabled = false
  config.acao.wp_sync_dry_run = true
  config.acao.wp_sync_debug = 0

  if config.respond_to?(:rails_vos)
    config.rails_vos.allowed_request_origins = [
      'http://linobis.acao.it:3330',
      'http://linobis.acao.it:3331',
      'http://linobis.acao.it:3332',
      'http://linobis.acao.it:4200',
      'http://linobis.acao.it:4201',
      'http://linobis.acao.it:4242',
      'http://dashboard-linobis.acao.it:3330',
      'http://dashboard-linobis.acao.it:3331',
      'http://dashboard-linobis.acao.it:3332',
      'http://dashboard-linobis.acao.it:4200',
      'http://dashboard-linobis.acao.it:4201',
      'http://services-linobis.acao.it:3330',
      'http://services-linobis.acao.it:3331',
      'http://services-linobis.acao.it:3332',
      'http://services-linobis.acao.it:4200',
      'http://services-linobis.acao.it:4201',
      'https://servizi-dev.acao.it',
      'https://servizi-dev-lilc.acao.it',
      'https://servizi-dev.lilc.acao.it',
    ]

    config.rails_vos.safe_receiver = true

    config.rails_vos.routes.merge!({
      'ygg.glideradar.processed_traffic.live.linobis': {
        type: :topic,
        durable: true,
        auto_delete: false,
        anonymous_access: true,
      },
      'ygg.autocam.state.linobis': {
        type: :topic,
        durable: true,
        auto_delete: false,
        anonymous_access: true,
      },
    })
  end

  if config.respond_to?(:amqp_ws_gw)
    config.amqp_ws_gw.allowed_request_origins = [
      'http://linobis.acao.it:3330',
      'http://linobis.acao.it:3331',
      'http://linobis.acao.it:3332',
      'http://linobis.acao.it:4200',
      'http://linobis.acao.it:4201',
      'http://linobis.acao.it:4242',
      'http://dashboard-linobis.acao.it:3330',
      'http://dashboard-linobis.acao.it:3331',
      'http://dashboard-linobis.acao.it:3332',
      'http://dashboard-linobis.acao.it:4200',
      'http://dashboard-linobis.acao.it:4201',
      'http://services-linobis.acao.it:3330',
      'http://services-linobis.acao.it:3331',
      'http://services-linobis.acao.it:3332',
      'http://services-linobis.acao.it:4200',
      'http://services-linobis.acao.it:4201',
      'https://servizi-dev.acao.it',
      'https://servizi-dev-lilc.acao.it',
      'https://servizi-dev.lilc.acao.it',
    ]

    config.amqp_ws_gw.safe_receiver = true

    config.amqp_ws_gw.routes.merge!({
      'ygg.glideradar.processed_traffic.live.linobis': {
        type: :topic,
        durable: true,
        auto_delete: false,
        anonymous_access: true,
      },
      'ygg.autocam.state.linobis': {
        type: :topic,
        durable: true,
        auto_delete: false,
        anonymous_access: true,
      },
    })
  end

  config.hosts.clear
end
