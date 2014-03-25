# encoding: utf-8
LinuxfrOrg::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb
  MY_DOMAIN = 'alpha.linuxfr.org'
  IMG_DOMAIN = 'img.alpha.linuxfr.org'

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  config.cache_store = :redis_store, "redis://localhost:6379/1/cache"

  # Set the page cache directory
  config.action_controller.page_cache_directory = "#{Rails.public_path}/pages"

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => MY_DOMAIN }
  config.action_mailer.delivery_method     = :sendmail
  config.action_mailer.sendmail_settings   = { :location  => "/usr/sbin/sendmail" }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
end
