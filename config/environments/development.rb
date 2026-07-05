Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  MY_DOMAIN  = ENV["DOMAIN"] || "dlfp.lo"
  MY_PUBLIC_PORT = ENV["DOMAIN_HTTP_PORT"] || "80"

  linuxfr_service_url = "http://#{MY_DOMAIN}"
  if MY_PUBLIC_PORT != "" and MY_PUBLIC_PORT != "80"
    linuxfr_service_url = "#{linuxfr_service_url}:#{ MY_PUBLIC_PORT}"
  end

  if MY_PUBLIC_PORT == "443"
    linuxfr_service_url = "https://#{MY_DOMAIN}"
  end
  MY_PUBLIC_URL = linuxfr_service_url


  IMG_DOMAIN = ENV["IMAGE_DOMAIN"] || "dlfp.lo"
  IMG_PUBLIC_PORT = ENV["IMAGE_DOMAIN_HTTP_PORT"] || "80"

  image_service_url = "http://#{IMG_DOMAIN}"
  if IMG_PUBLIC_PORT != "" and IMG_PUBLIC_PORT != "80"
    image_service_url = "#{image_service_url}:#{ IMG_PUBLIC_PORT}"
  end

  if IMG_PUBLIC_PORT == "443"
    image_service_url = "https://#{IMG_DOMAIN}"
  end
  IMG_PUBLIC_URL = image_service_url

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { host: MY_DOMAIN }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.action_controller.action_on_unpermitted_parameters = :raise
end
