# == Schema Information
#
# Table name: posts
#
#  id          :integer(4)      not null, primary key
#  state       :string(255)     default("published"), not null
#  title       :string(255)
#  cached_slug :string(255)
#  body        :text
#  wiki_body   :text
#  forum_id    :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

# The post is a question in the forums.
# The users post them for seeking help.
#
class Post < Content
  belongs_to :forum

  attr_accessible :title, :wiki_body

  validates_presence_of :forum,     :message => "Vous devez choisir un forum"
  validates_presence_of :title,     :message => "Le titre est obligatoire"
  validates_presence_of :wiki_body, :message => "Vous ne pouvez pas poster un journal vide"

  scope :published, where(:state => 'published')

  wikify_attr :body

### SEO ###

  has_friendly_id :title, :use_slug => true

### Sphinx ####

  define_index do
    indexes title, body
    indexes user.name, :as => :user
    indexes forum.title, :as => :forum, :facet => true
    where "posts.state = 'published'"
    set_property :field_weights => { :title => 10, :user => 4, :body => 2, :forum => 3 }
    set_property :delta => :datetime, :threshold => 75.minutes
  end

### ACL ###

  def editable_by?(user)
    user && (user.id == user_id || user.moderator? || user.admin?)
  end

  def deletable_by?(user)
    user && (user.moderator? || user.admin?)
  end

end
