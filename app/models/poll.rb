# == Schema Information
#
# Table name: polls
#
#  id          :integer(4)      not null, primary key
#  state       :string(255)     default("draft"), not null
#  title       :string(255)
#  cached_slug :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Poll < Content
  include AASM

  has_many :answers, :class_name => 'PollAnswer',
                     :dependent  => :destroy,
                     :order      => 'position',
                     :inverse_of => :poll
  accepts_nested_attributes_for :answers, :allow_destroy => true,
      :reject_if => proc { |attrs| attrs['answer'].blank? }

  attr_accessible :title, :answers_attributes

  validates_presence_of :title, :message => "La question est obligatoire"

  scope :sorted, order('created_at DESC')

### Associated node ###

  attr_accessor :user_id

  after_create :create_associated_node
  def create_associated_node
    create_node(:user_id => user_id, :public => false)
  end

### SEO ###

  has_friendly_id :title, :use_slug => true

### Sphinx ####

# TODO Rails 3
#   define_index do
#     indexes title
#     indexes user.name, :as => :user
#     indexes answers.answer, :as => :answers
#     where "state IN ('published', 'archived')"
#     set_property :field_weights => { :title => 10, :user => 3, :answers => 4 }
#     set_property :delta => :datetime, :threshold => 75.minutes
#   end

### Workflow ###

  aasm_column :state
  aasm_initial_state :draft

  aasm_state :draft
  aasm_state :published
  aasm_state :archived
  aasm_state :refused
  aasm_state :deleted

  aasm_event :accept  do transitions :from => [:draft],     :to => :published, :on_transition => :publish end
  aasm_event :refuse  do transitions :from => [:draft],     :to => :refused  end
  aasm_event :archive do transitions :from => [:published], :to => :archived end
  aasm_event :delete  do transitions :from => [:published], :to => :deleted  end

  # There can be only one current poll,
  # so we archive other polls when publish a new one.
  def publish
    Poll.published.each do |poll|
      poll.archive unless poll.id == self.id
    end
    node.update_attribute(:public, true)
  end

  def self.current
    published.first
  end

### ACL ###

  def viewable_by?(user)
    %w(published archived).include?(state) || (user && user.amr?)
  end

  def updatable_by?(user)
    user && user.amr?
  end

  def destroyable_by?(user)
    user && user.admin?
  end

  def acceptable_by?(user)
    user && user.amr?
  end

  def refusable_by?(user)
    user && user.amr?
  end

  def answerable_by?(ip)
    published? && !PollIp.has_voted?(ip)
  end

### Votes ###

  def total_votes
    @total_votes ||= answers.sum(:votes)
  end

### Interest ###

  def self.interest_coefficient
    10
  end

end
