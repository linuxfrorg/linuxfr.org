# Settings specified here will take precedence over those in config/environment.rb

# Host
MY_DOMAIN = 'linuxfr.org'
config.action_controller.asset_host      = "static.#{MY_DOMAIN}"
config.action_mailer.default_url_options = { :host => MY_DOMAIN }

# Full cache for best performances
config.cache_classes                      = true
config.action_controller.perform_caching  = true
config.action_view.cache_template_loading = true
# config.cache_store = :mem_cache_store

# Misc
config.action_controller.consider_all_requests_local = false
