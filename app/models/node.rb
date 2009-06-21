# == Schema Information
#
# Table name: nodes
#
#  id                :integer(4)      not null, primary key
#  content_id        :integer(4)
#  content_type      :string(255)
#  score             :integer(4)      default(0)
#  user_id           :integer(4)
#  public            :boolean(1)      default(TRUE)
#  created_at        :datetime
#  updated_at        :datetime
#  last_commented_at :datetime
#

# The node is attached to each content.
# It helps organizing some common stuff between the contents,
# and facilitates the transformation of one content to another.
#
class Node < ActiveRecord::Base
  belongs_to :user     # can be NULL
  belongs_to :content, :polymorphic => true
  has_many :comments
  has_many :readings, :dependent => :destroy
  has_many :votes, :dependent => :destroy
  has_many :taggings, :dependent => :destroy, :include => :tag
  has_many :tags, :through => :taggings, :uniq => true

  named_scope :public, :conditions => { :public => true }
  named_scope :by_date, :order => 'created_at DESC'
  named_scope :on_dashboard, lambda {|type|
    {:conditions => {:public => true, :content_type => type}, :order => 'created_at DESC'}
  }

### Comments ###

  def threads
    Threads.all(self.id)
  end

  def read_status(user)
    r = Reading.first(:conditions => {:user_id => user.id, :node_id => self.id}) if user
    return :not_read if r.nil?
    return :no_comments if last_commented_at.nil?
    return :new_comments if r.updated_at < last_commented_at
    return :read
  end

### Tags ###

  def can_be_tagged_by?(user)
    !!user # FIXME
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
