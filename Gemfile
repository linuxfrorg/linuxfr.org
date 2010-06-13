source "http://gemcutter.org"

gem "rails",                   "3.0.0.beta4"

# TODO Rails 3
# gem "aasm",                    "~>2.1"
gem "aasm", :git => "http://github.com/larspind/aasm.git"
gem "acts_as_list",            "~>0.1"
gem "canable",                 "~>0.1"
gem "compass",                 "~>0.10"
# TODO Rails 3
#gem "devise",                  "~>1.1.rc1"
gem "devise", :git => "http://github.com/plataformatec/devise.git"
gem "erubis",                  "~>2.6"
gem "french_rails",            "~>0.2"
gem "friendly_id",             "~>3.0"
gem "haml",                    "~>3.0"
gem "htmlentities",            "~>4.2"
gem "mysql",                   "~>2.8"
gem "nokogiri",                "~>1.4"
gem "paperclip",               "~>2.3"
gem "raspell",                 "~>1.1"
gem "rdiscount",               "~>1.6"
gem "redis",                   "~>2.0"
gem "sitemap_generator",       "~>0.3"
gem "simple_autocomplete",     "~>0.3"
gem "thin",                    "~>1.2"
# TODO Thinking Sphinx compatible with Rails3
# gem "thinking-sphinx",       "~>1.3", :require => "thinking_sphinx"
# gem "ts-datetime-delta",     "~>1.0", :require => "thinking_sphinx/deltas/datetime_delta"
gem "validates_url_format_of", "~>0.1"
gem "will_paginate",           ">=3.0.pre"
gem "yajl-ruby",               "~>0.7", :require => "yajl"

group :development do
  gem "annotate"
  gem "jslint_on_rails"
  gem "rails3-generators"
end

group :test do
  gem "rspec-rails",           ">=2.0.0.beta.11"
  gem "factory_girl_rails",    "~>1.0"
end

group :production do
  gem 'redis-store',           ">=1.0.0.beta2"
end
