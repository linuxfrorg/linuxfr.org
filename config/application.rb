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
      g.integration_tool :rspec
      g.test_framework   :rspec, :fixture_replacement => :factory_girl
    end

    config.after_initialize do
      ActionView::Base.sanitized_allowed_attributes.merge %w(data-id data-after)
      ActiveSupport::XmlMini.backend = "Nokogiri"
    end

    config.filter_parameters << :password << :password_confirmation

    config.encoding = "utf-8"

    # TODO config.cache_store = :redis_store
    config.session_store :cookie_store, :key => '_linuxfr.org_session'
  end
end
