namespace :linuxfr do
  desc "Daily crontab"
  task :daily => [
    :flush_poll_ips,
    :delete_old_passive_accounts,
    :delete_old_boards,
    'sitemap:refresh',
    'friendly_id:remove_old_slugs'
  ]

  desc "New day => the users can revote on polls"
  task :flush_poll_ips => :environment do
    PollIp.delete_all
  end

  desc "Delete old accounts that were never activated"
  task :delete_old_passive_accounts => :environment do
    Account.passive.delete_all(["created_at <= ?", DateTime.now - 2.days])
  end

  desc "Delete old messages in the boards"
  task :delete_old_boards => :environment do
    Board.delete_all(["created_at <= ? AND object_type = ?", DateTime.now - 12.hours, Board.free])
    Board.delete_all(["created_at <= ?", DateTime.now - 1.month])
  end
end
