LinuxfrOrg::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb
  MY_DOMAIN = 'linuxfr.org'

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
  config.cache_store = :redis_store, "redis://linuxfr.org:6379/0"

  # Set the page cache directory
  config.action_controller.page_cache_directory = Rails.public_path.join("pages")

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "static.#{MY_DOMAIN}"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => MY_DOMAIN }

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
end
