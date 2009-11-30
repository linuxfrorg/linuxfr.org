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

### License ###

  attr_accessor :cc_licensed
  attr_accessible :cc_licensed

  def create_node_with_license(attrs={}, replace_existing=true)
    attrs[:cc_licensed] = true if cc_licensed && cc_licensed != '0'
    create_node_without_license attrs, replace_existing
  end
  alias_method_chain :create_node, :license

### ACL ###

  def readable_by?(user)
    !deleted? || (user && user.admin?)
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
    user && !deleted? && self.user != user &&
        (Time.now - created_at) < 3.months &&
        user.account.nb_votes > 0          &&
        !user.votes.exists?(:node_id => node.id)
  end

  def taggable_by?(user)
    user && !deleted?
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

  def announce_vote?
    false
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
