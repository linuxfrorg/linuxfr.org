# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

# TODO rails3
# require 'thinking_sphinx/tasks' rescue LoadError
# require 'thinking_sphinx/deltas/datetime_delta/tasks' rescue LoadError
# require 'sitemap_generator/tasks' rescue LoadError
# require 'paperclip/tasks/paperclip_tasks'

if Rails.env.development?
  require 'jslint/tasks'
  JSLint.config_path = "config/jslint.yml"
  # gem install nono-railroad
  # require 'railroad/tasks/diagrams' rescue LoadError
end


Rails::Application.load_tasks
