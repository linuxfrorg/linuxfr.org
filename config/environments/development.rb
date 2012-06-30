# encoding: utf-8
LinuxfrOrg::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb
  MY_DOMAIN  = 'dlfp.lo'
  IMG_DOMAIN = 'dlfp.lo'

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Open mail in the browser
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { :host => MY_DOMAIN }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Assets
  config.assets.compress = false
  config.assets.debug = false

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5
end
