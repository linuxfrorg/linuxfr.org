# encoding: UTF-8
# == Schema Information
#
# Table name: news_versions
#
#  id          :integer          not null, primary key
#  news_id     :integer
#  user_id     :integer
#  version     :integer
#  title       :string(255)
#  body        :text
#  second_part :text
#  links       :text
#  created_at  :datetime
#

#
class NewsVersion < ActiveRecord::Base
  belongs_to :news
  belongs_to :user

  acts_as_list :column => 'version', :scope => :news

### Append-only ###

  before_update :raise_on_update
  def raise_on_update
    raise ActiveRecordError.new "On ne modifie pas les anciennes versions !"
  end

### Presentation ###

  def message
    "Révision n°#{self.version}"
  end

  def author_name
    user.try :name
  end
end
