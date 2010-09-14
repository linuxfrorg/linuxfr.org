# == Schema Information
#
# Table name: posts
#
#  id             :integer(4)      not null, primary key
#  title          :string(255)
#  cached_slug    :string(255)
#  body           :text
#  wiki_body      :text
#  truncated_body :text
#  forum_id       :integer(4)
#  owner_id       :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

# The post is a question in the forums.
# The users post them for seeking help.
#
class Post < Content
  belongs_to :forum
  belongs_to :owner, :class_name => 'User'

  attr_accessible :title, :wiki_body, :forum_id

  validates :forum,     :presence => { :message => "Vous devez choisir un forum" }
  validates :title,     :presence => { :message => "Le titre est obligatoire" }
  validates :wiki_body, :presence => { :message => "Vous ne pouvez pas poster un journal vide" }

  scope :sorted, order('created_at DESC')

  wikify_attr   :body
  truncate_attr :body

### SEO ###

  has_friendly_id :title, :use_slug => true, :scope => :forum, :reserved_words => %w(index nouveau)

### Sphinx ####

# TODO Thinking Sphinx
#   define_index do
#     indexes title, body
#     indexes owner.name, :as => :user
#     indexes forum.title, :as => :forum, :facet => true
#     where "posts.state = 'published'"
#     set_property :field_weights => { :title => 10, :user => 4, :body => 2, :forum => 3 }
#     set_property :delta => :datetime, :threshold => 75.minutes
#   end

### ACL ###

  def updatable_by?(user)
    user && (user.id == user_id || user.moderator? || user.admin?)
  end

  def destroyable_by?(user)
    user && (user.moderator? || user.admin?)
  end

end
