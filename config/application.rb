# encoding: utf-8
require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LinuxfrOrg
  class Application < Rails::Application
    config.load_defaults 7.0

    I18n.enforce_available_locales = true

    config.generators do |g|
      g.template_engine  :haml
      g.view_specs       false
      g.helper           false
      g.assets           false
    end

    config.after_initialize do
      ActiveSupport::XmlMini.backend = "Nokogiri"
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    config.time_zone = 'Paris'

    config.to_prepare do
      Doorkeeper::AuthorizationsController.layout "doorkeeper"
    end
  end
end
