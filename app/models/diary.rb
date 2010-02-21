# == Schema Information
#
# Table name: diaries
#
#  id          :integer(4)      not null, primary key
#  state       :string(255)     default("published"), not null
#  title       :string(255)
#  cached_slug :string(255)
#  owner_id    :integer(4)
#  body        :text
#  wiki_body   :text
#  created_at  :datetime
#  updated_at  :datetime
#

# The users can post on theirs diaries.
# They can be used for sharing ideas,
# informations, discussions and trolls.
#
class Diary < Content
  belongs_to :owner, :class_name => 'User'

  attr_accessible :title, :wiki_body

  validates_presence_of :title,     :message => "Le titre est obligatoire"
  validates_presence_of :wiki_body, :message => "Vous ne pouvez pas poster un journal vide"

  scope :sorted, order('created_at DESC')
  scope :published, where(:state => 'published')

  wikify_attr :body

### SEO ###

  # TODO Rails3
  # has_friendly_id :title, :use_slug => true

### Sphinx ####

# TODO Rails 3
#   define_index do
#     indexes title, body
#     indexes user.name, :as => :user
#     where "state = 'published'"
#     set_property :field_weights => { :title => 10, :user => 4, :body => 2 }
#     set_property :delta => :datetime, :threshold => 75.minutes
#   end

### ACL ###

  def creatable_by?(user)
    user # && user.karma > 0
  end

  def editable_by?(user)
    user && (user.moderator? || user.admin?)
  end

  def deletable_by?(user)
    user && (user.moderator? || user.admin?)
  end

end
