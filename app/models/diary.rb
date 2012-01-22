# encoding: utf-8
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
  self.table_name = "diaries"

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

  index_name 'contents'
  mapping do
    indexes :id,         :index    => :not_analyzed
    indexes :title,      :analyzer => 'french', :boost => 100
    indexes :body,       :analyzer => 'french'
    indexes :owner_name, :analyzer => 'keyword', :boost => 10, :as => 'owner.name'
    indexes :created_at, :type => 'date', :include_in_all => false
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
