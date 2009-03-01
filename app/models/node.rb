# == Schema Information
# Schema version: 20090209232103
#
# Table name: nodes
#
#  id           :integer(4)      not null, primary key
#  content_id   :integer(4)
#  content_type :string(255)
#  score        :integer(4)      default(0)
#  user_id      :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

# The node is attached to each content.
# It helps organizing some common stuff between the contents,
# and facilitates the transformation of one content to another.
#
class Node < ActiveRecord::Base
  belongs_to :user
  belongs_to :content, :polymorphic => true
  has_many :comments
  has_many :votes, :dependent => :destroy
  has_many :taggings, :dependent => :destroy, :include => :tag
  has_many :tags, :through => :taggings

  named_scope :by_date, :order => "created_at DESC"

### Comments ###

  def threads
    Threads.all(self.id)
  end

### Tags ###

  def set_taglist(list, user)
    list = TagList.from(list)
    self.class.transaction do
      list.each do |tagname|
        tag = Tag.find_or_create_by_name(tagname)
        taggings.create(:tag_id => tag.id, :user_id => user.id)
      end
    end
  end

  def taglist(opts={})
    list = tags.all(opts)
    TagList.new(list.map &:name)
  end

  def taglist_by(user)
    taglist(:conditions => {:user_id => user.id})
  end

end
