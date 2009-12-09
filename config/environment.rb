# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  config.frameworks -= [ :active_resource ]

  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.
  # You have to specify the :lib option for libraries, where the Gem name (sqlite3-ruby) differs from the file itself (sqlite3)
  require 'htmldiff'
  config.gem 'mysql', :version => '~>2.8'
  config.gem 'haml', :version => '~>2.2'
  config.gem 'raspell', :version => '~>1.1'
  config.gem 'htmlentities', :version => '~>4.2'
  config.gem 'friendly_id', :version => '~>2.2'
  config.gem 'paperclip', :version => '~>2.1'
  config.gem 'wikitext', :version => '~>1.9'
  config.gem 'authlogic', :version => '~>2.1'
  config.gem 'aasm', :version => '~>2.1'
  config.gem 'will_paginate', :version => '~>2.3'
  config.gem 'rest-client', :lib => 'restclient', :version => '~>1.0'
  config.gem 'thinking-sphinx', :lib => 'thinking_sphinx', :version => '~>1.3'
  config.gem 'ts-datetime-delta', :lib => 'thinking_sphinx/deltas/datetime_delta', :version => '~>1.0'
  #config.gem 'json', :version => '~>1.2'
  #ActiveSupport::JSON.backend = "JSONGem"
  #config.gem 'libxml-ruby', :version => '~>0.9'
  #ActiveSupport::XmlMini.backend = "LibXML"

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # The internationalization framework can be changed to have another default locale (standard is :en) or more load paths.
  # All files from config/locales/*.rb,yml are added automatically.
  # config.i18n.load_path << Dir[File.join(RAILS_ROOT, 'my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :fr
  config.action_controller.resources_path_names = {
    :new  => 'nouveau',
    :edit => 'modifier'
  }

  config.after_initialize do
    ActionView::Base.sanitized_allowed_attributes.merge %w(data-id data-after)
  end

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # Please note that observers generated using script/generate observer need to have an _observer suffix
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
end
