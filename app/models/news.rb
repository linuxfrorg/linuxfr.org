# == Schema Information
# Schema version: 20090110185148
#
# Table name: news
#
#  id         :integer(4)      not null, primary key
#  state      :string(255)     default("draft"), not null
#  title      :string(255)
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#

class News < ActiveRecord::Base
end
