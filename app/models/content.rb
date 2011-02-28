# Content is an abstract class (not mapped to a SQL table).
# It's use as the base class for each content type.
# It defines some common methods, particulary for ACL.
#
class Content < ActiveRecord::Base
  self.abstract_class = true
  include Canable::Ables

  has_one :node, :as => :content, :dependent => :destroy, :inverse_of => :content
  has_many :comments, :through => :node

  delegate :score, :user, :to => :node

  scope :with_node_ordered_by, lambda {|order| joins(:node).where("nodes.public = 1").order("nodes.#{order} DESC") }

### License ###

  attr_accessor   :cc_licensed, :owner_id
  attr_accessible :cc_licensed

  after_create :create_node
  def create_node(attrs={}, replace_existing=true)
    attrs[:cc_licensed] = true if cc_licensed && cc_licensed != '0'
    attrs[:user_id] = owner_id if owner_id
    attrs[:user_id] = owner.id if respond_to?(:owner) && owner
    node = build_node(attrs, replace_existing)
    node.save
    node
  end

### ACL ###

  def viewable_by?(account)
    visible? || account.try(:admin?)
  end

  def creatable_by?(account)
    account
  end

  def updatable_by?(account)
    account
  end

  def destroyable_by?(account)
    account
  end

  def commentable_by?(account)
    account && viewable_by?(account) && (Time.now - created_at) < 3.months
  end

  def votable_by?(account)
    account && visible?                        &&
        self.user != account.user              &&
        (Time.now - created_at) < 3.months     &&
        (account.nb_votes > 0 || account.amr?) &&
        !node.vote_by?(account.id)
  end

  def taggable_by?(account)
    account && visible? && viewable_by?(account)
  end

### Workflow ###

  def mark_as_deleted
    node.update_attribute(:public, false)
  end

  def visible?
    node.public?
  end

### Interest ###

  def self.interest_coefficient
    2
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
