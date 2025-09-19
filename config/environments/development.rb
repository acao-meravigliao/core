require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Make code changes take effect immediately without server restart.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing.
  config.server_timing = true

  # Enable/disable Action Controller caching. By default Action Controller caching is disabled.
  # Run rails dev:cache to toggle Action Controller caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.public_file_server.headers = { "cache-control" => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
  end

  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to :null_store to avoid any caching.
  config.cache_store = :memory_store

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Append comments with runtime information tags to SQL queries in logs.
  config.active_record.query_log_tags_enabled = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  config.rails_amqp.url = 'amqp://agent@linobis.acao.it'
  config.rails_amqp.debug = 1

  config.core.lc_enabled = false
  #config.core.lc_exchange = ''

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
