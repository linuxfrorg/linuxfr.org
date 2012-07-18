# encoding: utf-8
require File.expand_path('../boot', __FILE__)

require 'rails'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require "sprockets/railtie"

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

    config.assets.enabled = true
    config.assets.version = "1.0"
    config.assets.js_compressor = :uglifier
    config.assets.precompile += %w(IE9.js html5.js sorttable.js)
    config.assets.precompile += %w(mobile.css print.css)
    Dir.chdir(Rails.root.join "app/assets/stylesheets") do
      config.assets.precompile += Dir["contrib/*"].map {|s| s.sub /.scss$/, '' }
      config.assets.precompile += Dir["common/*"].map {|s| s.sub /.scss$/, '' }
      config.assets.precompile += Dir["pygments/*"].map {|s| s.sub /.scss$/, '' }
    end
  end
end
