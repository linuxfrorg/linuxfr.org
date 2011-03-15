# == Schema Information
#
# Table name: diaries
#
#  id             :integer(4)      not null, primary key
#  title          :string(160)     not null
#  cached_slug    :string(165)
#  owner_id       :integer(4)
#  body           :text
#  wiki_body      :text
#  truncated_body :text
#  created_at     :datetime
#  updated_at     :datetime
#

# The users can post on theirs diaries.
# They can be used for sharing ideas,
# informations, discussions and trolls.
#
class Diary < Content
  belongs_to :owner, :class_name => 'User'

  attr_accessible :title, :wiki_body

  validates :title,     :presence => { :message => "Le titre est obligatoire" },
                        :length   => { :maximum => 100, :message => "Le titre est trop long" }
  validates :wiki_body, :presence => { :message => "Vous ne pouvez pas poster un journal vide" }

  wikify_attr   :body
  truncate_attr :body

### SEO ###

  has_friendly_id :title, :use_slug => true, :scope => :owner, :reserved_words => %w(index nouveau)

### Sphinx ####

# TODO Thinking Sphinx
#   define_index do
#     indexes title, body
#     indexes owner.name, :as => :user
#     where "state = 'published'"
#     set_property :field_weights => { :title => 10, :user => 4, :body => 2 }
#     set_property :delta => :datetime, :threshold => 75.minutes
#   end

### ACL ###

  def creatable_by?(account)
    account && account.karma > 0
  end

  def updatable_by?(account)
    account && (account.moderator? || account.admin?)
  end

  def destroyable_by?(account)
    account && (account.moderator? || account.admin?)
  end

end
