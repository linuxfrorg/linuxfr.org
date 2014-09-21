# encoding: utf-8
require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module LinuxfrOrg
  class Application < Rails::Application
    I18n.enforce_available_locales = true

    config.generators do |g|
      g.template_engine  :haml
      g.test_framework   :rspec, fixture_replacement: :factory_girl
      g.view_specs       false
      g.helper           false
      g.assets           false
    end

    config.after_initialize do
      ActiveSupport::XmlMini.backend = "Nokogiri"
    end

    config.time_zone = 'Paris'

    config.to_prepare do
      Doorkeeper::AuthorizationsController.layout "doorkeeper"
    end

    config.assets.precompile += %w(IE9.js html5.js sorttable.js)
    config.assets.precompile += %w(mobile.css print.css)
    Dir.chdir(Rails.root.join "app/assets/stylesheets") do
      config.assets.precompile += Dir["contrib/*"].map {|s| s.sub /.scss$/, '' }
      config.assets.precompile += Dir["common/*"].map {|s| s.sub /.scss$/, '' }
      config.assets.precompile += Dir["pygments/*"].map {|s| s.sub /.scss$/, '' }
    end
  end
end
