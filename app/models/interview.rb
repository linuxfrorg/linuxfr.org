# == Schema Information
# Schema version: 20090324234852
#
# Table name: interviews
#
#  id                  :integer(4)      not null, primary key
#  state               :string(255)     default("draft"), not null
#  title               :string(255)
#  body                :text
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

  named_scope :public, :conditions => ["state != ?", :draft]

  validates_presence_of :title, :message => "Vous devez préciser la personne à interviewer"
  validates_presence_of :body,  :message => "Veuillez donner quelques informations sur la personne à interviewer"

  wikify :body

### SEO ###

  has_friendly_id :title, :use_slug => true

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
    assigned_to_user.try(:public_name) || 'Personne'
  end

  def reported_by
    user.try(:public_name) || "Pierre Tramo"
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

end
