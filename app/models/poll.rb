# encoding: utf-8
# == Schema Information
#
# Table name: polls
#
#  id                :integer          not null, primary key
#  state             :string(10)       default("draft"), not null
#  title             :string(128)      not null
#  cached_slug       :string(128)      not null
#  created_at        :datetime
#  updated_at        :datetime
#  wiki_explanations :text(16777215)
#  explanations      :text(16777215)
#

class Poll < Content
  self.table_name = "polls"
  self.type = "Sondage"

  has_many :answers,
    -> { order(:position) },
    class_name: 'PollAnswer',
    dependent: :destroy,
    inverse_of: :poll
  accepts_nested_attributes_for :answers, allow_destroy: true

  validates :title, presence: { message: "La question est obligatoire" },
                    length: { maximum: 128, message: "La question est trop longue" }

  wikify_attr :explanations

  scope :draft,     -> { where(state: "draft")     }
  scope :published, -> { where(state: "published") }
  scope :archived,  -> { where(state: "archived")  }

  before_validation :mark_answers_for_destruction
  def mark_answers_for_destruction
    answers.select {|answer| answer.answer.blank? }.each do |answer|
      if answer.persisted?
        answer.mark_for_destruction
      else
        answers.delete answer
      end
    end
  end

### Associated node ###

  def create_node(attrs={})
    attrs[:public] = false
    super attrs
  end

### SEO ###

  extend FriendlyId
  friendly_id

  def should_generate_new_friendly_id?
    title_changed?
  end

### Workflow ###

  state_machine :state, initial: :draft do
    event :accept  do transition :draft     => :published end
    event :refuse  do transition :draft     => :refused   end
    event :archive do transition :published => :archived  end
    event :delete  do transition :published => :deleted   end

    after_transition on: :accept, do: :publish
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
    %w(published archived).include?(state) || account.try(:amr?)
  end

  def updatable_by?(account)
    account.amr?
  end

  def destroyable_by?(account)
    account.admin?
  end

  def acceptable_by?(account)
    account.amr?
  end

  def refusable_by?(account)
    account.amr?
  end

  def answerable_by?(ip)
    published? && !has_voted?(ip)
  end

### Voters IP ###

   def has_voted?(ip)
     $redis.exists?("polls/#{self.id}/#{ip}")
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
    12
  end

end
