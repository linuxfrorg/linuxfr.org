# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

if defined?(Unicorn::HttpRequest)
  require 'gctools/oobgc'
  use GC::OOB::UnicornMiddleware
end

run Rails.application
Rails.application.load_server
