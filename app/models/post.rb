# encoding: utf-8
# == Schema Information
#
# Table name: posts
#
#  id             :integer          not null, primary key
#  forum_id       :integer
#  title          :string(160)      not null
#  cached_slug    :string(165)
#  body           :text
#  wiki_body      :text
#  truncated_body :text
#  created_at     :datetime
#  updated_at     :datetime
#

# The post is a question in the forums.
# The users post them for seeking help.
#
class Post < Content
  self.table_name = "posts"
  self.type = "Forum"

  belongs_to :forum

  attr_accessible :title, :wiki_body, :forum_id

  scope :with_node_ordered_by, lambda {|order| joins(:node).where("nodes.public = 1").order("nodes.#{order} DESC") }

  validates :forum,     :presence => { :message => "Vous devez choisir un forum" }
  validates :title,     :presence => { :message => "Le titre est obligatoire" },
                         :length   => { :maximum => 100, :message => "Le titre est trop long" }
  validates :wiki_body, :presence => { :message => "Vous ne pouvez pas poster un journal vide" }

  wikify_attr   :body
  truncate_attr :body

### SEO ###

  extend FriendlyId
  friendly_id

### Search ####

  mapping do
    indexes :id,         :index    => :not_analyzed
    indexes :created_at, :type => 'date', :include_in_all => false
    indexes :username,   :as => 'user.try(:name)',           :boost => 2,  :index => 'not_analyzed'
    indexes :forum,      :as => 'forum.title.tr ".-", "··"', :boost => 5,  :index => 'not_analyzed'
    indexes :title,      :analyzer => 'french',              :boost => 10
    indexes :body,       :analyzer => 'french'
  end

### ACL ###

  def updatable_by?(account)
    node.user_id == account.user_id || account.moderator? || account.admin?
  end

  def destroyable_by?(account)
    account.moderator? || account.admin?
  end

end
