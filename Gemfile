source :rubygems

gem "rails",                   "=3.0.5"

gem "acts_as_list",            "~>0.1"
gem "albino",                  "~>1.3"
gem "bitfields",               "~>0.3"
gem "canable",                 "~>0.1"
gem "carrierwave",             "~>0.5"
gem "devise",                  "~>1.1"
gem "french_rails",            "~>0.2"
gem "friendly_id",             "~>3.1"
gem "haml",                    "~>3.0"
gem "html_truncator",          "~>0.2"
gem "htmlentities",            "~>4.2"
gem "jammit",                  "~>0.5"
gem "kaminari",                "~>0.10"
gem "mini_magick",             "~>3.2"
gem "mysql2",                  "~>0.2"
gem "nokogiri",                "~>1.4"
gem "rdiscount",               "~>1.6"
gem "redis",                   "~>2.1"
gem "sanitize",                "~>2.0"
gem "sitemap_generator",       "~>1.4"
gem "simple_autocomplete",     "~>0.3"
gem "state_machine",           "~>0.9"
# TODO Rails3
# gem "thinking-sphinx",       "~>1.3", :require => "thinking_sphinx"
# gem "ts-datetime-delta",     "~>1.0", :require => "thinking_sphinx/deltas/datetime_delta"

# Rspec-rails must be in development for rake stats and in test for normal stuff
group :development, :test do
  gem "rspec-rails",           "~>2.5"
end

group :development do
  gem "annotate"
  gem "autotest"
  gem "capistrano"
  gem "haml-rails"
  gem "jquery-rails"
  gem "rails3-generators"
  gem "thin"
end

group :test do
  gem "factory_girl_rails",    "~>1.0"
  gem "faker",                 "~>0.9"
  gem "fuubar",                "~>0.0"
  gem "spork",                 "~>0.8"
  gem "webrat",                "~>0.7"
end

group :production do
  gem "unicorn",               "~>3.0"
  gem "nono-redis-store",      "~>1.0"
end
