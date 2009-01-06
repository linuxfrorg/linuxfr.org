# == Schema Information
# Schema version: 20090106000348
#
# Table name: news
#
#  id         :integer(4)      not null, primary key
#  title      :string(255)
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#

class News < ActiveRecord::Base
end
