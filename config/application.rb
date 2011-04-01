require File.expand_path('../boot', __FILE__)

require 'rails'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'

# Auto-require default libraries and those for the current Rails environment.
Bundler.require(:default, Rails.env) if defined?(Bundler)

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
  end
end
