source 'https://rubygems.org'

gem "rails",                   "4.1.1"

gem "actionpack-page_caching", "~>1.0"
gem "ansi",                    "~>1.4", require: nil
gem "acts_as_list",            "~>0.4"
gem "bitfields",               "~>0.4"
gem "canable",                 "~>0.1"
gem "carrierwave",             "~>0.10"
gem "devise",                  "~>3.2"
gem "diff_match_patch",        github: "nono/diff_match_patch-ruby", require: "diff_match_patch"
gem "french_rails",            "~>0.3"
gem "friendly_id",             "~>5.0"
gem "haml",                    "~>4.0"
gem "html-pipeline-linuxfr",   "~>0.14"
gem "html_spellchecker",       "~>0.1"
gem "html_truncator",          "~>0.4"
gem "htmlentities",            "~>4.3"
gem "inherited_resources",     "~>1.4"
gem "kaminari",                "~>0.15"
gem "mini_magick",             "~>3.7"
gem "mysql2",                  "~>0.3"
gem "nokogiri",                "~>1.6"
gem "oauth2",                  "~>0.6"
gem "patron",                  "~>0.4"
gem "rinku",                   "~>1.7"
gem "hiredis",                 "~>0.5"
gem "redis",                   "~>3.0", require: ["redis/connection/hiredis", "redis"]
gem "sanitize",                "~>2.1"
gem "sitemap_generator",       "~>2.1" # TODO update sitemap_generator
gem "state_machine",           "~>1.2"

# Use the github version to have transport auto-detection
gem "elasticsearch-transport", "~>1.0"

# Elasticsearch-model needs to be loaded after some gems like kaminari
gem "elasticsearch-model",     "~>0.1"

# Gems used for assets
gem "jquery-rails",          "~>3.1"
gem "sass-rails",            "~>4.0"
gem "coffee-rails",          "~>4.0"
gem "therubyracer",          "~>0.12", require: 'v8'
gem "uglifier"

# Rspec-rails must be in development for rake stats and in test for normal stuff
group :development, :test do
  gem "rspec-rails",           "~>2.14"
end

group :development do
  gem "annotate"
  gem "better_errors"
  gem "binding_of_caller"
  gem "capistrano",            "~>2.0"
  gem "capistrano-maintenance"
  gem "desi"
  gem "letter_opener"
  gem "mo"
  gem "pry-rails"
  gem "quiet_assets"
  gem "spring"
  gem "sushi"
  gem "thin"
end

group :test do
  gem "database_cleaner",      "~>1.2"
  gem "factory_girl_rails",    "~>1.6"
  gem "fuubar",                "~>1.0"
  gem "capybara",              "~>2.2"
end

group :production, :alpha do
  gem "unicorn",               "~>4.8"
  gem "gctools",               "~>0.2"
  gem "redis-activesupport",   "~>4.0"
end
