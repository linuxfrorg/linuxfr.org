ENV["RAILS_ENV"] ||= 'test'
require 'spork'


Spork.prefork do
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'factory_girl'

  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  RSpec.configure do |c|
    c.mock_with :rspec
    c.filter_run :focus => true
    c.run_all_when_everything_filtered = true
    c.include Devise::TestHelpers, :type => :controller
  end
end


Spork.each_run do
  $redis.select 15
end

