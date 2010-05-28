# == Schema Information
#
# Table name: nodes
#
#  id                :integer(4)      not null, primary key
#  content_id        :integer(4)
#  content_type      :string(255)
#  score             :integer(4)      default(0)
#  interest          :integer(4)      default(0)
#  user_id           :integer(4)
#  public            :boolean(1)      default(TRUE)
#  cc_licensed       :boolean(1)      default(FALSE)
#  comments_count    :integer(4)      default(0)
#  last_commented_at :datetime
#  created_at        :datetime
#  updated_at        :datetime
#

# The node is attached to each content.
# It helps organizing some common stuff between the contents,
# and facilitates the transformation of one content to another.
#
class Node < ActiveRecord::Base
  belongs_to :user     # can be NULL
  belongs_to :content, :polymorphic => true, :inverse_of => :node
  has_many :comments, :inverse_of => :node
  has_many :readings, :dependent => :destroy
  has_many :votes, :dependent => :destroy
  has_many :taggings, :dependent => :destroy, :include => :tag
  has_many :tags, :through => :taggings, :uniq => true

  scope :visible, where(:public => true)
  scope :by_date, order('created_at DESC')
  scope :public_listing, lambda {|type,order| visible.where(:content_type => type.to_s).order("#{order} DESC") }
  scope :on_dashboard, lambda {|type| public_listing(type, "created_at") }

### Interest ###

  after_create :compute_interest
  def compute_interest
    coeff = content_type.constantize.interest_coefficient
    stmt  = "UPDATE nodes SET interest=(score * #{coeff} + UNIX_TIMESTAMP(created_at) / 1000) WHERE id=#{self.id}"
    connection.update_sql(stmt)
  end

### Comments ###

  def threads
    Threads.all(self.id)
  end

  def read_status(user)
    r = Reading.where(:user_id => user.id, :node_id => self.id).first if user
    return :not_read if r.nil?
    return :no_comments if last_commented_at.nil?
    return :new_comments if r.updated_at < last_commented_at
    return :read
  end

### Tags ###

  def set_taglist(list, user)
    self.class.transaction do
      TagList.new(list).each do |tagname|
        tag = Tag.find_or_create_by_name(tagname)
        taggings.create(:tag_id => tag.id, :user_id => user.id)
      end
    end
  end

  def popular_tags(nb=7)
    Tag.joins(:taggings).
        where("taggings.node_id" => self.id).
        group("tags.id").
        order("COUNT(tags.id) DESC").
        limit(nb)
  end

end
