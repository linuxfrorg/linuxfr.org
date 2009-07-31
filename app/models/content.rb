# Content is an abstract class (not mapped to a SQL table).
# It's use as the base class for each content type.
# It defines some common methods, particulary for ACL.
#
class Content < ActiveRecord::Base
  self.abstract_class = true

  has_one :node, :as => :content, :dependent => :destroy
  has_one :user, :through => :node
  has_many :comments, :through => :node

  named_scope :sorted, :order => 'created_at DESC'
  delegate :score, :user_id, :to => :node

### ACL ###

  def readable_by?(user)
    state != 'deleted' || (user && user.admin?)
  end

  def creatable_by?(user)
    user
  end

  def editable_by?(user)
    user
  end

  def deletable_by?(user)
    user
  end

  def commentable_by?(user)
    user && readable_by?(user) && (Time.now - created_at) < 3.months
  end

  def votable_by?(user)
    user && readable_by?(user) &&
        self.user != user      &&
        user.votes.count(:conditions => {:node_id => node.id}) == 0
  end

### Workflow ###

  def mark_as_deleted
    node.update_attribute(:public, false)
    self.state = 'deleted'
    save
  end

### Interest ###

  def self.interest_coefficient
    3
  end

### Sitemap ###

  def lastmod
    [node.last_commented_at, updated_at].compact.max
  end

  def changefreq
    if created_at.today?
      'hourly'
    elsif created_at > 3.days.ago
      'daily'
    elsif created_at > 3.months.ago
      'monthly'
    else
      'yearly'
    end
  end

end
