source :rubygems

gem "rails",                   "~>3.1.0"

gem "acts_as_list",            "~>0.1"
gem "albino",                  "~>1.3"
gem "bitfields",               "~>0.4"
gem "canable",                 "~>0.1"
gem "carrierwave",             "~>0.5"
gem "devise",                  "~>1.4"
gem "differ",                  "~>0.1"
gem "french_rails",            "~>0.2"
gem "friendly_id",             "~>3.2"
gem "haml",                    "~>3.1"
gem "html_spellchecker",       "~>0.1"
gem "html_truncator",          "~>0.2"
gem "htmlentities",            "~>4.3"
gem "kaminari",                "~>0.12"
gem "mini_magick",             "~>3.3"
gem "mysql2",                  "~>0.3"
gem "nokogiri",                "~>1.5"
gem "rinku",                   "~>1.2"
gem "redcarpet",               "~>1.17"
gem "hiredis",                 "~>0.3"
gem "redis",                   "~>2.2", :require => ["redis/connection/hiredis", "redis"]
gem "sanitize",                "~>2.0"
gem "sitemap_generator",       "~>2.0"
gem "simple_autocomplete",     "~>0.3"
gem "state_machine",           "~>1.0"
# TODO Rails3
# gem "thinking-sphinx",       "~>1.3", :require => "thinking_sphinx"
# gem "ts-datetime-delta",     "~>1.0", :require => "thinking_sphinx/deltas/datetime_delta"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem "jquery-rails",          "~>1.0"
  gem "sass-rails",            "~>3.1"
  gem "coffee-rails",          "~>3.1"
  gem "uglifier"
end

# Rspec-rails must be in development for rake stats and in test for normal stuff
group :development, :test do
  gem "rspec-rails",           "~>2.6"
end

group :development do
  gem "annotate"
  gem "autotest-standalone"
  gem "capistrano"
  gem "capistrano_colors"
  gem "haml-rails"
  gem "pry"
  gem "thin"
end

group :test do
  gem "factory_girl_rails",    "~>1.1"
  gem "faker",                 "~>0.9"
  gem "fuubar",                "~>0.0"
  gem "spork",                 "~>0.8"
  gem "webrat",                "~>0.7"
end

group :production do
  gem "unicorn",               "~>4.0"
  gem "redis-store",           "~>1.0"
end
