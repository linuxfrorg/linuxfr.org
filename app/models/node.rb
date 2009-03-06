# == Schema Information
# Schema version: 20090301003336
#
# Table name: nodes
#
#  id           :integer(4)      not null, primary key
#  content_id   :integer(4)
#  content_type :string(255)
#  score        :integer(4)      default(0)
#  user_id      :integer(4)
#  public       :boolean(1)      default(TRUE)
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
  has_many :tags, :through => :taggings, :uniq => true

  named_scope :public, :conditions => {:public => true}
  named_scope :by_date, :order => "created_at DESC"

### Comments ###

  def threads
    Threads.all(self.id)
  end

### Tags ###

  def can_be_tagged_by?(user)
    true # FIXME
  end

  def set_taglist(list, user)
    list = TagList.from(list)
    self.class.transaction do
      list.each do |tagname|
        tag = Tag.find_or_create_by_name(tagname)
        taggings.create(:tag_id => tag.id, :user_id => user.id)
      end
    end
  end

  def popular_tags(nb=10)
    # FIXME We should count only taggings for this node for sorting tags
    tags.all(:order => 'taggings_count DESC', :limit => nb)
  end

end
