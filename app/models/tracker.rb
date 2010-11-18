# encoding: UTF-8
#
# == Schema Information
#
# Table name: trackers
#
#  id                  :integer(4)      not null, primary key
#  state               :string(255)     default("opened"), not null
#  title               :string(255)
#  cached_slug         :string(255)
#  body                :text
#  wiki_body           :text
#  truncated_body      :text
#  category_id         :integer(4)
#  assigned_to_user_id :integer(4)
#  created_at          :datetime
#  updated_at          :datetime
#

# There are no bugs in LinuxFr.org, but if it would happen,
# the users can report them in the tracker.
# They can also suggest improvements here.
#
class Tracker < Content
  belongs_to :assigned_to_user, :class_name => "User"
  belongs_to :category

  attr_accessible :title, :wiki_body, :category_id

  validates :title,     :presence => { :message => "Le titre est obligatoire" }
  validates :wiki_body, :presence => { :message => "Veuillez décrire cette entrée du suivi" }

  scope :sorted, order("created_at DESC")
  scope :opened, where(:state => "opened")

  wikify_attr   :body
  truncate_attr :body

### SEO ###

  has_friendly_id :title, :use_slug => true, :reserved_words => %w(index nouveau comments)

### Sphinx ####

# TODO Thinking Sphinx
#   define_index do
#     indexes title, body
#     indexes user.name, :as => :user
#     indexes category.title, :as => :category, :facet => true
#     set_property :field_weights => { :title => 2, :user => 1, :body => 1, :category => 1 }
#     set_property :delta => :datetime, :threshold => 75.minutes
#   end

### Workflow ###

  States = {'Ouverte' => :opened, 'Corrigée' => :fixed, 'Invalide' => :invalid}.freeze

  state_machine :state, :initial => :opened do
    event :fix        do transition :opened => :fixed   end
    event :invalidate do transition :opened => :invalid end
    event :reopen     do transition all     => :opened  end
  end

### Presentation ###

  def category_title
    category.try(:title) || 'Suivi'
  end

  def assigned_to
    assigned_to_user.try(:name) || 'Personne'
  end

  def reported_by
    user.try(:name) || "Pierre Tramo"
  end

### ACL ###

  def creatable_by?(account)
    true
  end

  def updatable_by?(account)
    account && (account.moderator? || account.admin?)
  end

  def destroyable_by?(account)
    account && (account.moderator? || account.admin?)
  end

  def commentable_by?(account)
    account && viewable_by?(account)
  end

end
