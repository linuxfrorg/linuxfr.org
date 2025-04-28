# encoding: UTF-8
# == Schema Information
#
# Table name: nodes
#
#  id                :integer          not null, primary key
#  content_id        :integer
#  content_type      :string(40)
#  user_id           :integer
#  public            :boolean          default(TRUE), not null
#  cc_licensed       :boolean          default(TRUE), not null
#  score             :integer          default(0), not null
#  interest          :integer          default(0), not null
#  comments_count    :integer          default(0), not null
#  last_commented_at :datetime
#  created_at        :datetime
#  updated_at        :datetime
#

#
# The node is attached to each content.
# It helps organizing some common stuff between the contents,
# and facilitates the transformation of one content to another.
#
class Node < ActiveRecord::Base
  belongs_to :user     # can be NULL
  belongs_to :content, polymorphic: true, inverse_of: :node
  has_many :comments, inverse_of: :node
  has_many :taggings, -> { includes(:tag) }, dependent: :destroy
  has_many :tags, -> { distinct }, through: :taggings

  scope :visible,        -> { where(public: true) }
  scope :by_date,        -> { order(created_at: :desc) }
  scope :published_on,   ->(d) { where(created_at: (d...d+1.day)) }
  scope :on_dashboard,   ->(types)  { public_listing(types, "created_at") }
  scope :sitemap,        ->(types) { public_listing(types, "id").where("score > 0") }
  scope :public_listing, ->(types, order) {
    types.map!(&:to_s) if types.is_a? Array
    types = types.to_s if types.is_a? Class
    visible.where(content_type: types).order("#{order} DESC")
  }

  paginates_per 15

### PPP ###

  def self.ppp
    id = $redis.get("nodes/ppp")
    find(id).try(:content) if id
  end

  def set_on_ppp
    $redis.set("nodes/ppp", self.id)
  end

  def on_ppp?
    self.id == $redis.get("nodes/ppp").to_i
  end

### Interest ###

  after_create :compute_interest
  def compute_interest
    coeff = content_type.constantize.interest_coefficient
    stmt  = "UPDATE nodes SET interest=(score * #{coeff} + UNIX_TIMESTAMP(created_at) / 1000) WHERE id=#{self.id}"
    Node.connection.update(stmt)
  end

  def make_visible
    self.public = true
    self.created_at = DateTime.now
    self.save
    compute_interest
  end

### Votes ###

  def vote_by?(account_id)
    $redis.exists("nodes/#{self.id}/votes/#{account_id}")
  end

  def vote_for(account)
    vote(account, 1)
  end

  def vote_against(account)
    vote(account, -1)
  end

  def vote(account, value)
    key  = "nodes/#{self.id}/votes/#{account.id}"
    prev = $redis.getset(key , value)
    return if prev.to_i == value
    value *= 2 if prev
    $redis.expire(key, 7776000) # 3 months
    $redis.incrby("users/#{self.user_id}/diff_karma", value) unless self.user_id.nil?
    Account.decrement_counter(:nb_votes, account.id) unless account.amr?
    Node.update_counters self.id, score: value
    compute_interest
    content.vote_on_candidate(value, account) if content_type == "News" && content.candidate?
  end

### Comments ###

  def threads
    @threads ||= Threads.all(self.id)
  end

  def latest_answer
    comments.latest_published.first
  end

### Readings ###

  def self.readings_keys_of(account_id)
    $redis.keys("readings/*/#{account_id}")
  end

  def self.readings_of(account_id)
    ids = readings_keys_of(account_id).map {|x| x.scan(/\/(\d+)\//).first.first }
    visible.where(id: ids)
  end

  def read_by(account_id)
    $redis.set("readings/#{self.id}/#{account_id}", Time.now.to_i)
    $redis.expire("readings/#{self.id}/#{account_id}", 7776000) # 3 months
  end

  def unread_by(account_id)
    $redis.del("readings/#{self.id}/#{account_id}")
  end

  def self.unread_all_by(account_id)
    keys = readings_keys_of(account_id)
    $redis.del(*keys) if keys.present?
  end

  def self.last_reading(node_id, account_id)
    time = $redis.get("readings/#{node_id}/#{account_id}")
    time && Time.at(time.to_i)
  end

  def read_status(account)
    return @read_status if @read_status
    r = Node.last_reading(self.id, account.id) if account
    @read_status = case
                   when r.nil?                 then :not_read
                   when last_commented_at.nil? then :no_comments
                   when r >= last_commented_at then :read
                   else comments.where("created_at > ?", r).count
                   end
  end

  def board_status(account)
    r = Node.last_reading(self.id, account.id) if account
    b = Board.last(content_type, content_id)
    return :not_read  if r.nil?
    return :new_board if b && r < b.created_at
    return :read
  end

### Tags ###

  attr_reader :preview_tags

  def preview_tags=(list)
    @preview_tags = TagList.new(list)
  end

  def set_taglist(list, user_id)
    self.class.transaction do
      TagList.new(list).each do |tagname|
        tag = Tag.find_or_initialize_by(name: tagname)
        if tag.new_record?
          tag.save!
          user = User.find(user_id)
          Board.amr_notification("L’étiquette #{tagname} https://#{MY_DOMAIN}/tags/#{tagname}/public vient d’être créée par #{user.name} https://#{MY_DOMAIN}/users/#{user.cached_slug}")
        end
        taggings.create(tag_id: tag.id, user_id: user_id)
      end
    end
  end

  def popular_tags(nb=7)
    Tag.select([:name]).
        where(public: true).
        joins(:taggings).
        where("taggings.node_id" => self.id).
        group("tags.id").
        order(Arel.sql("COUNT(tags.id) DESC")).
        limit(nb)
  end

  def tag_names
    tags.where(public: true).pluck(:name)
  end

end
