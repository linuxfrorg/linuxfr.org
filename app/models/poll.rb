# == Schema Information
#
# Table name: polls
#
#  id          :integer(4)      not null, primary key
#  state       :string(10)      default("draft"), not null
#  title       :string(128)     not null
#  cached_slug :string(128)
#  created_at  :datetime
#  updated_at  :datetime
#

class Poll < Content
  has_many :answers, :class_name => 'PollAnswer',
                     :dependent  => :destroy,
                     :order      => 'position',
                     :inverse_of => :poll
  accepts_nested_attributes_for :answers, :allow_destroy => true, :reject_if => :all_blank

  attr_accessible :title, :answers_attributes
  sanitize_attr :title

  validates :title, :presence => { :message => "La question est obligatoire" }

  scope :draft,     where(:state => "draft")
  scope :published, where(:state => "published")
  scope :archived,  where(:state => "archived")

### Associated node ###

  def create_node(attrs={}, replace_existing=true)
    attrs[:public] = false
    super attrs, replace_existing
  end

### SEO ###

  has_friendly_id :title, :use_slug => true, :reserved_words => %w(index nouveau)

### Sphinx ####

# TODO Thinking Sphinx
#   define_index do
#     indexes title
#     indexes user.name, :as => :user
#     indexes answers.answer, :as => :answers
#     where "state IN ('published', 'archived')"
#     set_property :field_weights => { :title => 10, :user => 3, :answers => 4 }
#     set_property :delta => :datetime, :threshold => 75.minutes
#   end

### Workflow ###

  state_machine :state, :initial => :draft do
    event :accept  do transition :draft     => :published end
    event :refuse  do transition :draft     => :refused   end
    event :archive do transition :published => :archived  end
    event :delete  do transition :published => :deleted   end

    after_transition :on => :accept, :do => :publish
  end

  # There can be only one current poll,
  # so we archive other polls when publish a new one.
  def publish
    Poll.published.each do |poll|
      poll.archive unless poll.id == self.id
    end
    node.make_visible
  end

  def self.current
    published.first
  end

### ACL ###

  def viewable_by?(account)
    %w(published archived).include?(state) || (account && account.amr?)
  end

  def updatable_by?(account)
    account && account.amr?
  end

  def destroyable_by?(account)
    account && account.admin?
  end

  def acceptable_by?(account)
    account && account.amr?
  end

  def refusable_by?(account)
    account && account.amr?
  end

  def answerable_by?(ip)
    published? && !has_voted?(ip)
  end

### Voters IP ###

   def has_voted?(ip)
     $redis.exists("polls/#{self.id}/#{ip}")
   end

   def vote(ip)
     $redis.set("polls/#{self.id}/#{ip}", 1)
     $redis.expire("polls/#{self.id}/#{ip}", 86400)
   end

### Votes ###

  def total_votes
    @total_votes ||= answers.sum(:votes)
  end

### Interest ###

  def self.interest_coefficient
    20
  end

end
