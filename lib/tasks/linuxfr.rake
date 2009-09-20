namespace :linuxfr do
  desc "Daily crontab"
  task :daily => [:flush_poll_ips]

  desc "New day => the users can revote on polls"
  task :flush_poll_ips => :environment do
    PollIp.delete_all
  end
end
