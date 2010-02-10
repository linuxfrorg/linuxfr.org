# == Schema Information
#
# Table name: interviews
#
#  id                  :integer(4)      not null, primary key
#  state               :string(255)     default("draft"), not null
#  title               :string(255)
#  cached_slug         :string(255)
#  body                :text
#  wiki_body           :text
#  news_id             :integer(4)
#  assigned_to_user_id :integer(4)
#  created_at          :datetime
#  updated_at          :datetime
#

# The users can suggest celebrities to interview.
# The comments are used for gathering the questions to ask.
#
class Interview < Content
  include AASM

  belongs_to :news
  belongs_to :assigned_to_user, :class_name => 'User'

  attr_accessible :title, :wiki_body

  scope :public, where("state != ?", :draft)

  validates_presence_of :title,     :message => "Vous devez préciser la personne à interviewer"
  validates_presence_of :wiki_body, :message => "Veuillez donner quelques informations sur la personne à interviewer"

  wikify_attr :body

### SEO ###

  has_friendly_id :title, :use_slug => true

### Sphinx ####

# TODO Rails 3
#   define_index do
#     indexes title, body
#     where "state != 'draft'"
#     set_property :field_weights => { :title => 20, :body => 4 }
#     set_property :delta => :datetime, :threshold => 75.minutes
#   end

### Workflow ###

  States = {'Proposition' => :draft, 'En cours' => :open, 'Envoyé' => :sent, 'Publié' => :published, 'Refusé' => :refused}.freeze

  aasm_column :state
  aasm_initial_state :draft

  aasm_state :draft
  aasm_state :open
  aasm_state :sent
  aasm_state :published
  aasm_state :refused

  aasm_event :accept  do transitions :from => [:draft], :to => :open end
  aasm_event :refuse  do transitions :from => [:draft, :open, :sent], :to => :refused end
  aasm_event :contact do transitions :from => [:open], :to => :sent end
  aasm_event :publish do transitions :from => [:open, :sent], :to => :published end

### Presentation ###

  def assigned_to
    assigned_to_user.try(:name) || 'Personne'
  end

  def reported_by
    user.try(:name) || "Pierre Tramo"
  end

### ACL ###

  def readable_by?(user)
    state != :draft || (user && user.amr?)
  end

  def editable_by?(user)
    user && user.amr?
  end

  def deletable_by?(user)
    user && user.amr?
  end

  def commentable_by?(user)
    user && readable_by?(user)
  end

  def acceptable_by?(user)
    user && user.amr?
  end

  def refusable_by?(user)
    user && user.amr?
  end

### Interest ###

  def self.interest_coefficient
    10
  end

end
