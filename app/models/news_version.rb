# encoding: UTF-8
# == Schema Information
#
# Table name: news_versions
#
#  id          :integer          not null, primary key
#  news_id     :integer          not null
#  user_id     :integer
#  version     :integer
#  title       :string(255)
#  body        :text(4294967295)
#  second_part :text(4294967295)
#  links       :text(16777215)
#  created_at  :datetime
#
class NewsVersion < ApplicationRecord
  belongs_to :news
  belongs_to :user, optional: true

  acts_as_list column: 'version', scope: :news

### Append-only ###

  before_update :raise_on_update
  def raise_on_update
    raise ActiveRecordError.new "On ne modifie pas les anciennes versions !"
  end

### Presentation ###

  def message
    "Révision nᵒ #{self.version}"
  end

  def author_name
    user.try :name
  end
end
