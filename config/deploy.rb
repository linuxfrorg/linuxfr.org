# encoding: utf-8
require 'bundler/capistrano'
require 'capistrano_colors'

# Assets
set :public_children, %w(images)
load 'deploy/assets'

# Common options
set :use_sudo,   false
set :scm,        :git
set :repository, "git://github.com/nono/linuxfr.org.git"
set :deploy_via, :remote_cache

default_run_options[:pty] = true


# We have two environments: alpha and prod.
# To make a deploy, precise on which environment, like this:
#   $ cap prod deploy
desc "Alpha environment"
task :alpha do
  set :vserver,   "alpha"
  set :user,      "alpha"
  set :branch,    $1 if `git branch` =~ /\* (\S+)\s/m
  set :rails_env, :alpha
end

desc "Production"
task :prod do
  set :vserver,   "prod"
  set :user,      "linuxfr"
  set :branch,    "master"
  set :rails_env, :production
end

desc "[internal] Common stuff to alpha and production"
task :common do
  set :application, "#{vserver}.linuxfr.org"
  set :deploy_to,   "/data/#{vserver}/#{user}/#{rails_env}"
  server "#{user}@#{application}", :app, :web, :db, :primary => true
  depend :remote, :file, "#{shared_path}/config/database.yml"
  depend :remote, :file, "#{shared_path}/config/secret.yml"
end
after "alpha", "common"
after "prod",  "common"


# Check that we have invoked an environment before deploying
before :deploy do
  unless exists?(:deploy_to)
    raise "Please invoke me like `cap env:<server> deploy` where <server> is prod or alpha"
  end
end


# Symlinks to share files/dirs between deploys
namespace :fs do
  desc "[internal] Install some symlinks to share files between deploys."
  task :symlink, :roles => :app, :except => { :no_release => true } do
    symlinks = %w(config/database.yml config/secret.yml public/pages tmp/sass-cache tmp/sockets uploads)
    symlinks.each do |symlink|
      run "ln -nfs #{shared_path}/#{symlink} #{release_path}/#{symlink}"
    end
    run "ln -nfs ~/historique #{release_path}/public/images/"
    run "ln -nfs ~/load #{release_path}/public/images/"
  end

  desc "[internal] Create the shared directories"
  task :create_dirs, :roles => :app do
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/public/pages"
    run "mkdir -p #{shared_path}/tmp/sass-cache"
    run "mkdir -p #{shared_path}/tmp/sockets"
    run "mkdir -p #{shared_path}/uploads/avatars"
    run "mkdir -p #{shared_path}/uploads/stylesheets"
  end
end
after "deploy:finalize_update", "fs:symlink"
after "deploy:setup", "fs:create_dirs"


# Redis cache
namespace :cache do
  desc "Flush the redis cache"
  task :flush, :roles => :app do
    run "redis-cli -n 1 flushdb"
  end
end
after "deploy:finalize_update", "cache:flush"


# The hard-core deployment rules
namespace :deploy do
  task :start, :roles => :app do
    run "cd #{current_path} && bundle exec unicorn -c config/unicorn.rb -E #{rails_env} -D"
  end

  task :stop, :roles => :app do
    set :unicorn_pidfile, "#{shared_path}/pids/unicorn.pid"
    run "if [ -e #{unicorn_pidfile} ] ; then kill -QUIT `cat #{unicorn_pidfile}` ; fi"
  end

  task :restart, :roles => :app, :except => { :no_release => true }  do
    set :unicorn_pid, capture("cat #{shared_path}/pids/unicorn.pid").chomp
    run "kill -USR2 #{unicorn_pid}"
    sleep 1
    run "kill -QUIT #{unicorn_pid}"
  end

  task :cold, :roles => :app do
    stop
    update
    migrate
    start
  end

  namespace :web do
    task :disable, :roles => :web, :except => { :no_release => true } do
      on_rollback { run "rm #{shared_path}/system/maintenance.html" }
      require 'erb'
      reason, deadline = ENV['REASON'], ENV['deadline']
      template = File.read(File.join(File.dirname(__FILE__), "templates", "maintenance.rhtml"))
      result = ERB.new(template).result(binding)
      put result, "#{shared_path}/system/maintenance.html", :mode => 0644
    end
  end
end
before "deploy:cold", "deploy:web:disable"
after  "deploy:cold", "deploy:web:enable"
after  "deploy:create_symlink", "deploy:cleanup"
