ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails/test_help'

class ActiveSupport::TestCase
  # No fixtures, we use Factory-Girl instead

  # Add more helper methods to be used by all tests here...
end
