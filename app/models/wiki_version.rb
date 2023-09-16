# encoding: UTF-8
# == Schema Information
#
# Table name: wiki_versions
#
#  id           :integer          not null, primary key
#  wiki_page_id :integer          not null
#  user_id      :integer
#  version      :integer
#  message      :string(255)
#  body         :text(4294967295)
#  created_at   :datetime
#

#
class WikiVersion < ActiveRecord::Base
  belongs_to :user, optional: true
  belongs_to :wiki_page
  has_one :node, through: :wiki_page

  acts_as_list column: 'version', scope: :wiki_page

  validates :message, length: { maximum: 255, message: "Le message est trop long" }

### Append-only ###

  before_update :raise_on_update
  def raise_on_update
    raise ActiveRecordError.new "On ne modifie pas les anciennes versions !"
  end

### Presentation ###

  def message
    msg = read_attribute(:message)
    msg.blank? ? "Révision nᵒ #{self.id}" : msg
  end

  def author_name
    user.try :name
  end
end
