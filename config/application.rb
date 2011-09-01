require File.expand_path('../boot', __FILE__)

require 'rails'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module LinuxfrOrg
  class Application < Rails::Application
    config.generators do |g|
      g.template_engine  :haml
      g.test_framework   :rspec, :fixture_replacement => :factory_girl
    end

    config.after_initialize do
      ActiveSupport::XmlMini.backend = "Nokogiri"
    end

    config.encoding = "utf-8"
    config.time_zone = 'Paris'

    config.filter_parameters += [:password, :password_confirmation]

    COOKIE_STORE_KEY = 'linuxfr.org_session'
    config.session_store :cookie_store, :key => COOKIE_STORE_KEY

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end
end
