ENV["RAILS_ENV"] ||= 'test'
require 'factory_girl'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'rspec/rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Rspec.configure do |config|
  require 'rspec/expectations'
  config.include Rspec::Matchers
  config.mock_with :rspec
end
