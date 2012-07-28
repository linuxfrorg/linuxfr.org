# encoding: utf-8
# == Schema Information
#
# Table name: diaries
#
#  id             :integer          not null, primary key
#  title          :string(160)      not null
#  cached_slug    :string(165)
#  owner_id       :integer
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
  self.table_name = "diaries"
  self.type = "Journal"

  belongs_to :owner, :class_name => 'User'

  attr_accessible :title, :wiki_body

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
    indexes :username,   :as => 'owner.name',   :boost => 3,               :index => 'not_analyzed'
    indexes :title,      :analyzer => 'french', :boost => 10
    indexes :body,       :analyzer => 'french'
  end

### ACL ###

  def creatable_by?(account)
    account.karma > 0
  end

  def updatable_by?(account)
    account.moderator? || account.admin?
  end

  def destroyable_by?(account)
    account.moderator? || account.admin?
  end

end
