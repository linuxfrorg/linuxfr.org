# == Schema Information
# Schema version: 20090105235401
#
# Table name: news
#
#  id         :integer(4)      not null, primary key
#  title      :string(255)
#  body       :text
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class News < ActiveRecord::Base
  belongs_to :user
end
