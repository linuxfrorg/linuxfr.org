# encoding: utf-8
# == Schema Information
#
# Table name: comments
#
#  id                :integer          not null, primary key
#  node_id           :integer          not null
#  user_id           :integer
#  state             :string(10)       default("published"), not null
#  title             :string(160)      not null
#  score             :integer          default(0), not null
#  answered_to_self  :boolean          default(FALSE), not null
#  materialized_path :string(1022)
#  body              :text(4294967295)
#  wiki_body         :text(16777215)
#  created_at        :datetime
#  updated_at        :datetime
#

# The users can comment any content.
# Those comments are threaded and can be noted.
#
class Comment < ActiveRecord::Base
  include Canable::Ables

  belongs_to :user
  belongs_to :node, counter_cache: :comments_count

  delegate :content, :content_type, to: :node

  scope :under,        ->(path) { where("materialized_path LIKE ?", "#{path}_%") }
  scope :published,    -> { where(state: 'published') }
  scope :on_dashboard, -> { published.order(created_at: :desc) }
  scope :latest_published, -> {
    published.
    order(created_at: :desc).
    limit(1)
  }
  scope :footer,       -> {
    # MariaDB tries to scan nodes first, which is a very slow, so we add an index hint
    from("comments USE INDEX (index_comments_on_state_and_created_at)").published.
      joins(:node).merge(Node.visible).
      order(created_at: :desc).
      limit(12).
      select([:id, :node_id, :title])
  }

  validates :title,     presence: { message: "Le titre est obligatoire" },
                        length: { maximum: 100, message: "Le titre est trop long" }
  validates :wiki_body, presence: { message: "Vous ne pouvez pas poster un commentaire vide" }

  wikify_attr :body
  def wikify_body
    nofollow = user.account.blank? || user.account.karma < 50
    self.body = wikify(wiki_body, nofollow: nofollow)
  end

### Reading status ###

  # Returns true if this comment has been read by the given user,
  # but also for anonymous users
  def read_by?(account)
    return true if account.nil?
    r = Node.last_reading(node_id, account.id)
    r && r >= created_at
  end

  before_create :touch_node
  def touch_node
    node.touch(:last_commented_at) if node
  end

### Threads ###

  PATH_SIZE = 12  # Each id in the materialized_path is coded on 12 chars
  MAX_DEPTH = 1022 / PATH_SIZE
  EDITION_PERIOD_IN_MINUTES = 5

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
    @parent = node.comments.find(parent_id)
    return if @parent.blank? || @parent.deleted?
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
    Comment.where(node_id: node_id, user_id: user_id).
            where("LOCATE(materialized_path, ?) > 0", materialized_path).
            where("id != ?", self.id).
            exists?
  end

  def children?
    Comment.where(node_id: node_id, user_id: user_id).
            where("materialized_path LIKE '#{materialized_path}%'").
            where("id != ?", self.id).
            exists?
  end

  def parents
    Comment.where(node_id: node_id).
            where("LOCATE(materialized_path, ?) = 1", materialized_path).
            where("id != ?", self.id)
  end

  def edition_period
    return EDITION_PERIOD_IN_MINUTES
  end

### Notifications ###

  after_create :notify_parents
  def notify_parents
    parents.each do |p|
      next if p.user_id == user_id
      account = p.user.try(:account)
      account.notify_answer_on node_id if account
    end
  end

  after_create :notify_node_owner
  def notify_node_owner
    if user_id != node.user_id 
      node_owner = node.user.try(:account)
      node_owner.notify_answer_on node_id if node_owner
    end
  end

### Calculations ###

  before_validation :default_score, on: :create
  def default_score
    if user.account.karma > 0
      self.score = Math.log10(user.account.karma).to_i - 1
      self.score = [self.score, 1].max if content_type == 'Post'
    else
      self.score = [-2 + user.account.karma/30, -10].max
    end
  end

  def nb_answers
    self.class.published.under(materialized_path).count
  end

  def latest_answer
    self.class.published.under(materialized_path).last
  end

### ACL ###

  def viewable_by?(account)
    state != 'deleted' || account.try(:admin?)
  end

  def creatable_by?(account)
    node && node.content && node.content.commentable_by?(account) && !account.blocked?
  end

  def updatable_by?(account)
    account.moderator? || account.admin? ||
      (user_id == account.user_id && created_at >= EDITION_PERIOD_IN_MINUTES.minutes.ago && !children?)
  end

  def destroyable_by?(account)
    account.moderator? || account.admin?
  end

  def votable_by?(account)
    !deleted? && user_id != account.user_id    &&
        (Time.now - created_at) < 3.months     &&
        (account.nb_votes > 0 || account.amr?) &&
        !vote_by?(account.id)
  end

### Votes ###

  def vote_by?(account_id)
    %w(for against).find {|w| $redis.sismember("comments/#{self.id}/votes/#{w}", account_id) }
  end

  def vote_for(account)
    vote(account, :for) && Comment.increment_counter(:score, self.id)
  end

  def vote_against(account)
    vote(account, :against) && Comment.decrement_counter(:score, self.id)
  end

  def vote(account, what)
    value = what == :for ? 1 : -1
    key = "comments/#{self.id}/votes/#{what}"
    return false unless $redis.sadd(key, account.id)
    $redis.expire(key, 7776000) # 3 months
    unless score * (score + value) > 100  # Score is out of the [-10, 10] bounds
      $redis.incrby("users/#{self.user_id}/diff_karma", value) unless self.user_id.nil?
    end
    Account.decrement_counter(:nb_votes, account.id)
    true
  end

  def nb_votes_for
    $redis.scard "comments/#{self.id}/votes/for"
  end

  def nb_votes_against
    $redis.scard "comments/#{self.id}/votes/against"
  end

### Workflow ###

  def mark_as_deleted
    self.state = 'deleted'
    save
  end

  def deleted?
    state == 'deleted'
  end

### Statistics ###

  after_create :compute_stats
  def compute_stats
    return unless node
    today = Date.today
    $redis.incr "stats/comments/year/#{today.year}/#{content_type}"
    $redis.incr "stats/comments/month/#{today.strftime "%Y%m"}/#{content_type}"
    $redis.incr "stats/comments/wday/#{(today.wday - 1) % 7}"
  end

### Presentation ###

  def user_name
    user.try :name
  end

  def bound_score
    [[score, -10].max, 10].min
  end

end
