source :rubygems

gem "rails",                   "~>3.2.9"

gem "acts_as_list",            "~>0.1.6"
gem "albino",                  "~>1.3"
gem "bitfields",               "~>0.4"
gem "canable",                 "~>0.1"
gem "carrierwave",             "~>0.6"
gem "devise",                  "~>2.0"
gem "differ",                  "~>0.1"
gem "french_rails",            "~>0.2"
gem "friendly_id",             "~>4.0"
gem "haml",                    "~>3.1"
gem "html_spellchecker",       "~>0.1"
gem "html_truncator",          "~>0.3"
gem "htmlentities",            "~>4.3"
gem "inherited_resources",     "~>1.2"
gem "kaminari",                "~>0.12"
gem "mini_magick",             "~>3.3"
gem "mysql2",                  "~>0.3"
gem "nokogiri",                "~>1.5"
gem "oauth2",                  "~>0.6"
gem "rinku",                   "~>1.2"
gem "redcarpet",               "~>2.1"
gem "hiredis",                 "~>0.3"
gem "redis",                   "~>2.2", :require => ["redis/connection/hiredis", "redis"]
gem "sanitize",                "~>2.0"
gem "sitemap_generator",       "~>2.1"
gem "simple_autocomplete",     "~>0.3"
gem "state_machine",           "~>1.1"
gem "tire",                    "~>0.4"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem "jquery-rails",          "~>1.0"
  gem "sass-rails",            "~>3.2"
  gem "coffee-rails",          "~>3.2"
  gem "libv8",                 "~>3.11"
  gem "therubyracer",          "~>0.9", :require => 'v8'
  gem "uglifier"
end

# Rspec-rails must be in development for rake stats and in test for normal stuff
group :development, :test do
  gem "rspec-rails",           "~>2.9"
end

group :development do
  gem "annotate"
  gem "autotest-standalone"
  gem "better_errors"
  gem "capistrano"
  gem "capistrano-maintenance"
  gem "haml-rails"
  gem "letter_opener"
  gem "mo"
  gem "pry-rails"
  gem "quiet_assets"
  gem "desi"
  gem "thin"
end

group :test do
  gem "database_cleaner",      "~>0.7"
  gem "factory_girl_rails",    "~>1.6"
  gem "faker",                 "~>0.9"
  gem "fuubar",                "~>1.0"
  gem "spork",                 "~>0.9"
  gem "webrat",                "~>0.7"
end

group :production do
  gem "unicorn",               "~>4.3"
  gem "redis-activesupport",   "~>3.2"
end
