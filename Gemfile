source "http://gemcutter.org"

gem "rails",                   "3.0.0.beta3"

# TODO Rails 3
# gem "aasm",                    "~>2.1"
gem "aasm", :git => "http://github.com/larspind/aasm.git"
gem "acts_as_list",            "~>0.1"
gem "canable",                 "~>0.1"
gem "compass",                 "~>0.10"
gem "devise",                  "~>1.1.rc1"
gem "erubis",                  "~>2.6"
gem "french_rails",            "~>0.2"
gem "friendly_id",             "~>3.0"
gem "haml",                    "~>3.0"
gem "htmlentities",            "~>4.2"
gem "mysql",                   "~>2.8"
gem "nokogiri",                "~>1.4"
# TODO Rails 3
# gem "paperclip",               "~>2.3"
gem "paperclip", :git => "git://github.com/nono/paperclip.git", :branch => 'rails3'
gem "raspell",                 "~>1.1"
gem "rdiscount",               "~>1.6"
# TODO Rails 3
gem "redis-store", :git => "http://github.com/nono/redis-store.git", :branch => 'rails3'
gem "rest-client",             "~>1.5", :require => "restclient"
gem "sitemap_generator",       "~>0.3"
gem "simple_autocomplete",     "~>0.3"
gem "thin",                    "~>1.2"
# TODO Rails 3
# gem "thinking-sphinx",       "~>1.3", :require => "thinking_sphinx"
#gem "thinking-sphinx", :git => "git://github.com/nono/thinking-sphinx.git", :branch => "rails3", :require => "thinking_sphinx"
#gem "thinking-sphinx", :path => "../thinking-sphinx", :require => "thinking_sphinx"
# gem "ts-datetime-delta",     "~>1.0", :require => "thinking_sphinx/deltas/datetime_delta"
gem "validates_url_format_of", "~>0.1"
gem "will_paginate",           ">=3.0.pre"
gem "yajl-ruby",               "~>0.7", :require => "yajl"

group :development do
  gem "annotate"
  gem "jslint_on_rails"
  gem "rails3-generators"
  gem 'newrelic_rpm', :require => false
end

group :test do
  gem "rspec-rails",           ">=2.0.0.beta.9"
  # TODO Rails 3
  #gem "factory_girl",          ">=1.2.5"
  gem "factory_girl", :git => "git://github.com/thoughtbot/factory_girl.git", :branch => "fixes_for_rails3"
end
