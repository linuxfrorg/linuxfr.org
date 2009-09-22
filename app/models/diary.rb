# == Schema Information
#
# Table name: diaries
#
#  id         :integer(4)      not null, primary key
#  state      :string(255)     default("published"), not null
#  title      :string(255)
#  cache_slug :string(255)
#  owner_id   :integer(4)
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#

# The users can post on theirs diaries.
# They can be used for sharing ideas,
# informations, discussions and trolls.
#
class Diary < Content
  belongs_to :owner, :class_name => 'User'

  validates_presence_of :title, :message => "Le titre est obligatoire"
  validates_presence_of :body,  :message => "Vous ne pouvez pas poster un journal vide"

  named_scope :published, :conditions => { :state => 'published' }

  wikify :body

### SEO ###

  has_friendly_id :title

### Sphinx ####

  define_index do
    indexes title, body
    indexes user.name, :as => :user
    where "state = 'published'"
    set_property :field_weights => { :title => 10, :user => 4, :body => 2 }
    set_property :delta => :datetime, :threshold => 1.hour
  end

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
