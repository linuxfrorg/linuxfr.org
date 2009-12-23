# Be sure to restart your server when you modify this file

RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.frameworks -= [ :active_resource ]

  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.
  config.gem 'aasm', :version => '~>2.1'
  config.gem 'acts-as-list', :lib => 'acts_as_list', :version => '~>0.1'
  config.gem 'authlogic', :version => '~>2.1'
  config.gem 'erubis', :version => '~>2.6'
  config.gem 'french_rails', :version => '~>0.1'
  config.gem 'friendly_id', :version => '~>2.2'
  config.gem 'haml', :version => '~>2.2'
  config.gem 'htmlentities', :version => '~>4.2'
  config.gem 'mysql', :version => '~>2.8'
  config.gem 'paperclip', :version => '~>2.3'
  config.gem 'raspell', :version => '~>1.1'
  config.gem 'rest-client', :lib => 'restclient', :version => '~>1.0'
  config.gem 'sitemap_generator', :lib => false, :version => '~>0.2'
  config.gem 'simple_autocomplete', :version => '~>0.3'
  config.gem 'thinking-sphinx', :lib => 'thinking_sphinx', :version => '~>1.3'
  config.gem 'ts-datetime-delta', :lib => 'thinking_sphinx/deltas/datetime_delta', :version => '~>1.0'
  config.gem 'wikitext', :version => '~>1.9'
  config.gem 'will_paginate', :version => '~>2.3'
  #config.gem 'json', :version => '~>1.2'
  #ActiveSupport::JSON.backend = "JSONGem"
  #config.gem 'libxml-ruby', :version => '~>0.9'
  #ActiveSupport::XmlMini.backend = "LibXML"

  config.after_initialize do
    ActionView::Base.sanitized_allowed_attributes.merge %w(data-id data-after)
  end

  config.active_record.schema_format = :sql
end
