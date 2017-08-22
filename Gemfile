source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "rails",                   "~>5.1.3"

gem "actionpack-page_caching", "~>1.1"
gem "ansi",                    "~>1.4", require: nil
gem "acts_as_list",            "~>0.4"
gem "bitfields",               "~>0.4"
gem "canable",                 "~>0.1"
gem "carrierwave",             "~>1.1"
gem "devise",                  "~>4.3"
gem "diff_match_patch",        github: "nono/diff_match_patch-ruby", require: "diff_match_patch"
gem "doorkeeper",              "~>4.2"
gem "ffi-hunspell",            github: "postmodern/ffi-hunspell"
gem "french_rails",            "~>0.4"
gem "friendly_id",             "~>5.1"
gem "haml",                    "~>5.0"
gem "html-pipeline-linuxfr",   "~>0.15"
gem "html_spellchecker",       "~>0.1"
gem "html_truncator",          "~>0.4"
gem "htmlentities",            "~>4.3"
gem "inherited_resources",     "~>1.7"
gem "kaminari",                "~>0.15"
gem "mini_magick",             "~>3.8"
gem "mysql2",                  "~>0.3"
gem "nokogiri",                "1.6.5"  # FIXME see https://github.com/sparklemotion/nokogiri/issues/1233
gem "rinku",                   "~>1.7"
gem "hiredis",                 "~>0.5"
gem "redis",                   "~>3.0", require: ["redis/connection/hiredis", "redis"]
gem "sitemap_generator",       "~>2.1"
gem "state_machine",           "~>1.2"

# Gems used for assets
gem "jquery-rails",          "~>4.0"
gem "sass-rails",            "~>5.0"
gem "coffee-rails",          "~>4.1"
gem "therubyracer",          "~>0.12", require: 'v8'
gem "uglifier"

# Rspec-rails must be in development for rake stats and in test for normal stuff
group :development, :test do
  gem "rspec-rails",           "~>3.2"
end

group :development do
  gem "annotate"
  gem "better_errors"
  gem "binding_of_caller"
  gem "byebug",                platform: :mri
  gem "capistrano",            "~>2.15", github: 'capistrano', branch: 'legacy-v2'
  gem "capistrano-maintenance"
  gem "letter_opener"
  gem "listen"
  gem "mo"
  gem "pry-rails"
  gem "spring"
  gem "sushi"
  gem "thin"
  gem "web-console"
end

group :test do
  gem "database_cleaner",      "~>1.2"
  gem "factory_girl_rails",    "~>1.6"
  gem "fuubar",                "~>2.0"
  gem "capybara",              "~>2.4"
end

group :production, :alpha do
  gem "unicorn",               "~>5.1"
  gem "gctools",               "~>0.2"
  gem "redis-activesupport",   "~>5.0"
end
