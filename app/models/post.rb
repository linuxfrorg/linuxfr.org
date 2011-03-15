# == Schema Information
#
# Table name: posts
#
#  id             :integer(4)      not null, primary key
#  forum_id       :integer(4)
#  title          :string(160)     not null
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
  belongs_to :forum

  attr_accessible :title, :wiki_body, :forum_id

  validates :forum,     :presence => { :message => "Vous devez choisir un forum" }
  validates :title,     :presence => { :message => "Le titre est obligatoire" },
                         :length   => { :maximum => 100, :message => "Le titre est trop long" }
  validates :wiki_body, :presence => { :message => "Vous ne pouvez pas poster un journal vide" }

  wikify_attr   :body
  truncate_attr :body

### SEO ###

  has_friendly_id :title, :use_slug => true, :scope => :forum, :reserved_words => %w(index nouveau)

### Sphinx ####

# TODO Thinking Sphinx
#   define_index do
#     indexes title, body
#     indexes user.name, :as => :user
#     indexes forum.title, :as => :forum, :facet => true
#     where "posts.state = 'published'"
#     set_property :field_weights => { :title => 10, :user => 4, :body => 2, :forum => 3 }
#     set_property :delta => :datetime, :threshold => 75.minutes
#   end

### ACL ###

  def updatable_by?(account)
    account && (node.user_id == account.user_id || account.moderator? || account.admin?)
  end

  def destroyable_by?(account)
    account && (account.moderator? || account.admin?)
  end

end
