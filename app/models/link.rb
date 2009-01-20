# == Schema Information
# Schema version: 20090120005239
#
# Table name: links
#
#  id         :integer(4)      not null, primary key
#  news_id    :integer(4)
#  title      :string(255)
#  url        :string(255)
#  lang       :string(255)
#  nb_clicks  :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Link < ActiveRecord::Base
  belongs_to :news
end
