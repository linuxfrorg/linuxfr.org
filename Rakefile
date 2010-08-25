# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

if Rails.env.development?
  require 'jslint/tasks'
  JSLint.config_path = "config/jslint.yml"
end

LinuxfrOrg::Application.load_tasks
