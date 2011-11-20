# encoding: UTF-8
#
# == Schema Information
#
# Table name: wiki_versions
#
#  id           :integer(4)      not null, primary key
#  wiki_page_id :integer(4)
#  user_id      :integer(4)
#  version      :integer(4)
#  message      :string(255)
#  body         :text
#  created_at   :datetime
#

class WikiVersion < ActiveRecord::Base
  belongs_to :wiki_page
  belongs_to :user

  acts_as_list :column => 'version', :scope => :wiki_page

### Append-only ###

  before_update :raise_on_update
  def raise_on_update
    raise ActiveRecordError.new "On ne modifie pas les anciennes versions !"
  end

### Presentation ###

  def message
    msg = read_attribute(:message)
    msg.blank? ? "Révision n°#{self.id}" : msg
  end

  def author_name
    user.try :name
  end
end
