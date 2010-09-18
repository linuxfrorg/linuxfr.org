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


# Symlinks to share files/dirs between deploys
namespace :fs do
  desc "[internal] Install some symlinks to share files between deploys."
  task :symlink, :roles => :app, :except => { :no_release => true } do
    symlinks = %w(config/database.yml sockets)
    symlinks.each do |symlink|
      run "ln -nfs #{shared_path}/#{symlink} #{release_path}/#{symlink}"
    end
  end

  desc "[internal] Create the shared directories"
  task :create_dirs, :roles => :app do
    run "test -d #{shared_path}/sockets || mkdir #{shared_path}/sockets"
  end
end
after "deploy:finalize_update", "fs:symlink"
after "deploy:setup", "fs:create_dirs"


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
    run "unicorn -c #{release_path}/config/unicorn.rb -E #{rails_env} -D"
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
