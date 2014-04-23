# encoding: utf-8
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

RSpec.configure do |c|
  c.filter_run focus: true
  c.run_all_when_everything_filtered = true

  c.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end
  c.before(:each) do
    DatabaseCleaner.start
    $redis.flushdb
  end
  c.after(:each) do
    DatabaseCleaner.clean
  end
end

$redis.select 15
