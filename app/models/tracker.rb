# encoding: UTF-8
#
# == Schema Information
#
# Table name: trackers
#
#  id                  :integer(4)      not null, primary key
#  state               :string(10)      default("opened"), not null
#  title               :string(100)     not null
#  cached_slug         :string(105)
#  category_id         :integer(4)
#  assigned_to_user_id :integer(4)
#  body                :text
#  wiki_body           :text
#  truncated_body      :text
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

  attr_accessible :title, :wiki_body, :category_id, :assigned_to_user_id

  validates :title,     :presence => { :message => "Le titre est obligatoire" },
                        :length   => { :maximum => 100, :message => "Le titre est trop long" }
  validates :wiki_body, :presence => { :message => "Veuillez décrire cette entrée du suivi" }

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

  States = { "opened" => "Ouverte", "fixed" => "Corrigée", "invalid" => "Invalide" }.freeze

  state_machine :state, :initial => :opened do
    event :fix        do transition :opened => :fixed   end
    event :invalidate do transition :opened => :invalid end
    event :reopen     do transition all     => :opened  end
  end

### Presentation ###

  def state_name
    States[state].downcase
  end

  def category_title
    category.try(:title) || 'Suivi'
  end

  def assigned_to
    assigned_to_user.try(:name) || 'Personne'
  end

### ACL ###

  def creatable_by?(account)
    true
  end

  def updatable_by?(account)
    account && (account.moderator? || account.admin? || account.user_id == node.user_id)
  end

  def destroyable_by?(account)
    account && (account.moderator? || account.admin?)
  end

  def commentable_by?(account)
    account && viewable_by?(account)
  end

end
