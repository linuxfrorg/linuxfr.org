require 'bundler/capistrano'

# Common options
set :use_sudo,   false
set :scm,        :git
set :repository, "git://github.com/nono/linuxfr.org.git"
set :branch,     "master"
set :deploy_via, :remote_cache

default_run_options[:pty] = true # Temporary hack


# We have two environments: alpha and production.
# To make a deploy, precise on which environment, like this:
#   $ cap production deploy
namespace :env do
  desc "Alpha environment"
  task :alpha do
    set :vserver,   "alpha"
    set :user,      "alpha"
    set :rails_env, :alpha
  end

  desc "Production"
  task :production do
    set :vserver,   "web"
    set :user,      "linuxfr"
    set :rails_env, :production
  end

  desc "[internal] Common stuff to alpha and production"
  task :common do
    set :application, "#{vserver}.linuxfr.org"
    set :deploy_to,   "/data/#{vserver}/#{user}/#{rails_env}"
    server "#{user}@#{application}", :app, :web, :db, :primary => true
    depend :remote, :file, "#{shared_path}/config/database.yml"
  end
end
after "env:alpha", "env:common"
after "env:production", "env:common"


# Check that we have invoked an environment before deploying
before :deploy do
  unless exists?(:deploy_to)
    raise "Please invoke me like `cap env:<server> deploy` where <server> is production or alpha"
  end
end


# Config/database.yml
namespace :db do
  desc "[internal] Updates the symlink for database.yml file to the just deployed release."
  task :symlink, :roles => :app, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end
after "deploy:finalize_update", "db:symlink"


# Watch the logs
namespace :logs do
  desc "Watch jobs log"
  task :default do
    run "tail -f #{current_path}/log/#{rails_env}.log"
  end
end


# The hard-core deployment rules
namespace :deploy do
  task :start, :roles => :app do
    run "unicorn -c #{shared_path}/config/thin.yml -E #{rails_env} -D"
  end

  task :stop, :rules => :app do
    pid = File.read("#{shared_path}/pids/unicorn.pid").chomp
    run "kill -QUIT #{pid}"
  end

  task :restart, :roles => :app, :except => { :no_release => true }  do
    pid = File.read("#{shared_path}/pids/unicorn.pid").chomp
    run "kill -USR2 #{pid}"
    sleep 1
    run "kill -QUIT #{pid}"
  end
end
