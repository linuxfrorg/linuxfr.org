# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'
require 'thinking_sphinx/tasks' rescue LoadError
require 'thinking_sphinx/deltas/datetime_delta/tasks' rescue LoadError
require 'sitemap_generator/tasks' rescue LoadError

if Rails.env == 'development'
  # gem install nono-railroad
  require 'railroad/tasks/diagrams' rescue LoadError
end

