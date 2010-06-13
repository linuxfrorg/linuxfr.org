namespace :linuxfr do
  desc "Daily crontab"
  task :daily => [
    :delete_old_passive_accounts,
    :delete_old_votes,
    :daily_karma,
    'sitemap:refresh',
    'friendly_id:remove_old_slugs'
  ]

  desc "New day => update karma and give new votes"
  task :daily_karma => :environment do
    Account.find_each {|a| a.daily_karma }
  end

  desc "Delete old accounts that were never activated"
  task :delete_old_passive_accounts => :environment do
    Account.where(:confirmed_at => nil).where(["created_at <= ?", DateTime.now - 2.days]).delete_all
  end

  desc "Delete old votes on contents and comments (users cannot vote on them)"
  task :delete_old_votes => :environment do
    Vote.old.delete_all
    Relevance.old.delete_all
  end
end
