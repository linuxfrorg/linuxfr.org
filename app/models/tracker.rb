# == Schema Information
# Schema version: 20090209232103
#
# Table name: trackers
#
#  id                  :integer(4)      not null, primary key
#  state               :string(255)     default("open"), not null
#  title               :string(255)
#  body                :text
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
  include AASM

  belongs_to :assigned_to_user, :class_name => "User"
  belongs_to :category

  validates_presence_of :title, :message => "Le titre est obligatoire"
  validates_presence_of :body,  :message => "Veuillez décrire cette entrée du suivi"

  wikify :body

### SEO ###

  has_friendly_id :title, :use_slug => true

### Sphinx ####

  define_index do
    indexes title, body
    indexes user.name, :as => :user
    indexes category.title, :as => :category, :facet => true
    set_property :field_weights => { :title => 2, :user => 1, :body => 1, :category => 1 }
    set_property :delta => :datetime, :threshold => 1.hour
  end

### Workflow ###

  States = {'Ouvert' => :open, 'Fermé' => :fix, 'Invalide' => :invalid}.freeze

  aasm_column :state
  aasm_initial_state :open

  aasm_state :open
  aasm_state :fixed
  aasm_state :invalid

  aasm_event :fix        do transitions :from => [:open], :to => :fixed   end
  aasm_event :invalidate do transitions :from => [:open], :to => :invalid end
  aasm_event :reopen     do transitions :from => [:fixed, :invalid], :to => :open end

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

  def creatable_by?(user)
    true
  end

  def editable_by?(user)
    user && (user.moderator? || user.admin?)
  end

  def deletable_by?(user)
    user && (user.moderator? || user.admin?)
  end

  def commentable_by?(user)
    user && readable_by?(user)
  end

end
