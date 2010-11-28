ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(Rails)
require 'rspec/rails'
require 'factory_girl'

RSpec.configure do |c|
  c.mock_with :rspec
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
end

Webrat.configure do |c|
  c.mode = :rack
  c.open_error_files = false # prevents webrat from opening the browser
end

class ActionController::TestCase
  include Devise::TestHelpers
end

# http://pivotallabs.com/users/rolson/blog/articles/1249-stubbing-out-paperclip-imagemagick-in-tests
module Paperclip
  def self.run cmd, params = "", expected_outcodes = 0
    case cmd
    when "identify"
      return "100x100"
    when "convert"
      return
    else
      super
    end
  end
end

class Paperclip::Attachment
  def post_process
  end
end

$redis.select 15
