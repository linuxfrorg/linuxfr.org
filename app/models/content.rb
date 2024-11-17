# encoding: utf-8
# Content is an abstract class (not mapped to a SQL table).
# It's use as the base class for each content type.
# It defines some common methods, particulary for ACL.
#
class Content < ApplicationRecord
  self.abstract_class = true
  include Canable::Ables

  has_one :node, as: :content, dependent: :destroy, inverse_of: :content
  has_many :comments, through: :node

  # /!\ No scope here /!\

  delegate :score, :user, :set_on_ppp, :on_ppp?, :tag_names, to: :node

  class << self; attr_accessor :type; end

  def label_for_expand
    "Lire la suite"
  end

  def alternative_formats
    true
  end

### License ###

  attr_accessor :cc_licensed, :tmp_owner_id

  after_create :create_node
  def create_node(attrs={}, replace_existing=true)
    attrs[:cc_licensed] = cc_licensed != '0' if cc_licensed
    attrs[:user_id] = tmp_owner_id if tmp_owner_id
    attrs[:user_id] = owner.id if respond_to?(:owner) && owner
    node = build_node attrs
    node.save
    node
  end

### ACL ###

  def viewable_by?(account)
    visible? || account.try(:admin?)
  end

  def creatable_by?(account)
    true
  end

  def updatable_by?(account)
    true
  end

  def destroyable_by?(account)
    true
  end

  def commentable_by?(account)
    viewable_by?(account) && !too_old_for_comments?
  end

  def too_old_for_comments?
    (Time.now - node.created_at) > 3.months
  end

  def votable_by?(account)
    visible? && self.user != account.user      &&
        (account.nb_votes > 0 || account.amr?) &&
        !node.vote_by?(account.id)
  end

  def taggable_by?(account)
    visible? && viewable_by?(account)
  end

### Workflow ###

  def mark_as_deleted
    node.update_column(:public, false)
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
