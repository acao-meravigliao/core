# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = false

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with cache-control for performance.
  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  # Show full error reports.
  config.consider_all_requests_local = true
  config.cache_store = :null_store

  # Render exception templates for rescuable exceptions and raise for other exceptions.
  config.action_dispatch.show_exceptions = :rescuable

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  config.rails_amqp.url = 'amqp://agent@linobis.acao.it'
  config.rails_amqp.debug = 1

  config.core.lc_enabled = false
  config.core.lc_exchange = 'ygg.model.events'

  config.ml.email_disabled = true
  config.ml.email_redirect_to = 'daniele@orlandi.com'
  config.ml.sms_disabled = true
  config.ml.sms_redirect_to = '+393474659309'
  config.ml.sms_skebby_debug = 2
  config.ml.mailman_sync_disabled = true

  if config.respond_to?(:acao)
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

    config.acao.satispay_endpoint = 'https://staging.authservices.satispay.com/'
    config.acao.satispay_callback_url = 'http://linobis.acao.it:4201/ygg/acao/payments/satispay_callback?payment_id={uuid}'
    config.acao.satispay_redirect_url = 'http://linobis.acao.it:4201/authen/payment/redirect-back'
    config.acao.bar_add_maindb_transaction = false

    config.acao.wp_sync_disabled = true
    config.acao.wp_sync_dry_run = true
    config.acao.wp_sync_debug = 0
  end

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
end
