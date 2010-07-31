# Content is an abstract class (not mapped to a SQL table).
# It's use as the base class for each content type.
# It defines some common methods, particulary for ACL.
#
class Content < ActiveRecord::Base
  self.abstract_class = true

  has_one :node, :as => :content, :dependent => :destroy, :inverse_of => :content
  has_one :user, :through => :node
  has_many :comments, :through => :node

  delegate :score, :user_id, :to => :node

### License ###

  attr_accessor   :cc_licensed, :owner_id
  attr_accessible :cc_licensed

  after_create :create_node
  def create_node(attrs={}, replace_existing=true)
    attrs[:cc_licensed] = true if cc_licensed && cc_licensed != '0'
    attrs[:user_id] = owner_id if owner_id
    node = build_node(attrs, replace_existing)
    node.save
    node
  end

### ACL ###

  def viewable_by?(user)
    !deleted? || (user && user.admin?)
  end

  def creatable_by?(user)
    user
  end

  def updatable_by?(user)
    user
  end

  def destroyable_by?(user)
    user
  end

  def commentable_by?(user)
    user && viewable_by?(user) && (Time.now - created_at) < 3.months
  end

  def votable_by?(user)
    user && !deleted? && self.user != user &&
        (Time.now - created_at) < 3.months &&
        user.account.nb_votes > 0          &&
        !node.vote_by?(user.id)
  end

  def taggable_by?(user)
    user && !deleted? && viewable_by?(user)
  end

### Workflow ###

  def mark_as_deleted
    node.update_attribute(:public, false)
    self.state = 'deleted'
    save
  end

  def deleted?
    state == 'deleted'
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
