# == Schema Information
#
# Table name: comments
#
#  id                :integer(4)      not null, primary key
#  node_id           :integer(4)
#  user_id           :integer(4)
#  state             :string(10)      default("published"), not null
#  title             :string(160)     not null
#  score             :integer(4)      default(0), not null
#  answered_to_self  :boolean(1)      default(FALSE), not null
#  materialized_path :string(1022)
#  body              :text
#  wiki_body         :text
#  created_at        :datetime
#  updated_at        :datetime
#

# The users can comment any content.
# Those comments are threaded and can be noted.
#
class Comment < ActiveRecord::Base
  include Canable::Ables

  belongs_to :user
  belongs_to :node, :touch => :last_commented_at, :counter_cache => :comments_count

  delegate :content, :content_type, :to => :node

  attr_accessible :title, :wiki_body, :node_id, :parent_id

  scope :published,    where(:state => 'published')
  scope :under,        lambda { |path| where("materialized_path LIKE ?", "#{path}_%") }
  scope :on_dashboard, published.order('created_at DESC')
  scope :footer,       published.order('created_at DESC').limit(12)

  validates :title,     :presence => { :message => "Le titre est obligatoire" },
                        :length   => { :maximum => 100, :message => "Le titre est trop long" }
  validates :wiki_body, :presence => { :message => "Vous ne pouvez pas poster un commentaire vide" }

  wikify_attr :body

### Sphinx ####

# TODO Thinking Sphinx
#   define_index do
#     indexes title, body
#     indexes user.name, :as => :user
#     where "state = 'published'"
#     set_property :field_weights => { :title => 5, :user => 2, :body => 1 }
#     set_property :delta => :datetime, :threshold => 75.minutes
#   end

### Reading status ###

  # Returns true if this comment has been read by the given user,
  # but also for anonymous users
  def read_by?(account)
    return true if account.nil?
    r = Node.last_reading(node_id, account.id)
    r && r >= created_at
  end

### Threads ###

  PATH_SIZE = 12  # Each id in the materialized_path is coded on 12 chars
  MAX_DEPTH = 1022 / PATH_SIZE

  after_create :generate_materialized_path
  def generate_materialized_path
    parent = Comment.find(parent_id) if parent_id.present?
    parent_path = parent ? parent.materialized_path : ''
    self.materialized_path = "%s%0#{PATH_SIZE}d" % [parent_path, self.id]
    self.answered_to_self  = answer_to_self?
    save
  end

  def parent_id
    @parent_id ||= materialized_path && materialized_path[-2 * PATH_SIZE .. - PATH_SIZE - 1].to_i
    @parent_id
  end

  def parent_id=(parent_id)
    @parent_id = parent_id
    return if parent_id.blank?
    @parent = Comment.find(parent_id)
    self.title ||= @parent ? "#{@parent.title.starts_with?('Re:') ? '' : 'Re: '}#{@parent.title}" : ''
  end

  attr_reader :parent

  def depth
    (materialized_path.length / PATH_SIZE) - 1
  end

  def root?
    depth == 0
  end

  def answer_to_self?
    return false if root?
    ret = Comment.where(:node_id => node_id, :user_id => user_id).
                  where("LOCATE(materialized_path, ?) > 0", self.materialized_path).
                  where("id != ?", self.id).
                  exists?
  end

### Calculations ###

  before_validation :default_score, :on => :create
  def default_score
    self.score = Math.log10([user.account.karma, 0.1].max).to_i - 1
  end

  def nb_answers
    self.class.published.under(materialized_path).count
  end

  def last_answer
    self.class.published.under(materialized_path).last
  end

### ACL ###

  def viewable_by?(account)
    state != 'deleted' || account.try(:admin?)
  end

  def creatable_by?(account)
    node && node.content && node.content.commentable_by?(account)
  end

  def updatable_by?(account)
    account && (account.moderator? || account.admin?)
  end

  def destroyable_by?(account)
    account && (account.moderator? || account.admin?)
  end

  def votable_by?(account)
    account && !deleted?                       &&
        self.user != account.user              &&
        (Time.now - created_at) < 3.months     &&
        (account.nb_votes > 0 || account.amr?) &&
        !vote_by?(account.id)
  end

### Votes ###

  def vote_by?(account_id)
    $redis.exists("comments/#{self.id}/votes/#{account_id}")
  end

  def vote_for(account)
    vote(account, 1) && Comment.increment_counter(:score, self.id) unless score >= 10
  end

  def vote_against(account)
    vote(account, -1) && Comment.decrement_counter(:score, self.id) unless score <= -10
  end

  def vote(account, value)
    key = "comments/#{self.id}/votes/#{account.id}"
    return false if $redis.getset(key , value)
    $redis.expire(key, 7776000) # 3 months
    $redis.incrby("users/#{self.user_id}/diff_karma", value)
    Account.decrement_counter(:nb_votes, account.id)
    true
  end

### Workflow ###

  def mark_as_deleted
    self.state = 'deleted'
    save
  end

  def deleted?
    state == 'deleted'
  end

### Presentation ###

  def user_name
    user.try :name
  end

end
