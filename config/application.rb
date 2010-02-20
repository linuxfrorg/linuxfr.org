require File.expand_path('../boot', __FILE__)

require 'rails'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'

# Auto-require default libraries and those for the current Rails environment.
Bundler.require :default, Rails.env

module LinuxfrOrg
  class Application < Rails::Application
    config.generators do |g|
      g.orm              :active_record
      g.template_engine  :haml
      g.integration_tool :rspec
      g.test_framework   :rspec, :fixture_replacement => :factory_girl
    end

    config.after_initialize do
      ActionView::Base.sanitized_allowed_attributes.merge %w(data-id data-after)
    end

    config.filter_parameters << :password << :password_confirmation
  end
end
