# encoding: utf-8

# It's the famous board, from DaCode (then templeet)
#
class Board
  include ActiveModel::Model
  include Canable::Ables

  NB_MSG_PER_CHAN = 100

### Constructors and attributes ###

  attr_accessor :id, :user_name, :user_url, :user_agent, :object_type, :object_id, :message, :created_at

  validates :message, presence: true

  def initialize(params={})
    @object_type = Board.free
    @created_at  = Time.now
    super
    @object_id   = nil if @object_id.blank?
  end

  def user=(user)
    if @object_type == Board.free
      @user_name = user.account.login
    else
      @user_name = user.name
    end
    @user_url  = "/users/#{user.to_param}"
  end

  def user_link
    (@user_url.blank? ? @user_name : "<a href=\"#{@user_url}\">#{@user_name}</a>").html_safe
  end

### Save boards ###

  def save
    return false unless valid?
    clean
    persist
    push
    true
  end

  def persist
    @id = $redis.incr("boards/id")
    $redis.hmset("boards/msg/#{@id}", :msg, @message, :ua, @user_agent, :user, @user_name, :url, @user_url, :date, @created_at.to_i)
    $redis.lpush(chan_key, @id)
    $redis.lrange(chan_key, NB_MSG_PER_CHAN, -1).each do |i|
      $redis.del "boards/msg/#{i}"
    end
    $redis.ltrim(chan_key, 0, NB_MSG_PER_CHAN - 1)
  end

  def persisted?
    !!@id
  end

  def push
    rendered = BoardsController.new.render_to_body(partial: "board", locals: { board: self, box: false })
    Push.create(meta, kind: :chat, message: rendered)
  end

  def self.chan_key(object_type, object_id)
    ["boards/chans", object_type.downcase, object_id].compact.join('/')
  end

  def chan_key
    self.class.chan_key(@object_type, @object_id)
  end

### Sanitizing messages ###

  include ERB::Util
  include ActionView::Helpers::SanitizeHelper

  ALLOWED_TAGS = %w(b i u s strong em code)

  def clean
    @message    = sanitize_message @message
    @user_agent = h @user_agent.to_s.encode(Encoding::UTF_8)
    @user_name  = h @user_name
    @user_url   = h @user_url
  end

  def sanitize_message(msg)
    doc = Nokogiri::HTML::Document.new
    doc.encoding = "utf-8"
    node = Nokogiri::HTML::DocumentFragment.new(doc)
    inner_sanitize(node, msg[0, 500])
    msg = Rinku.auto_link(node.to_s, :urls) { "[url]" }
    sanitize(msg, tags: ALLOWED_TAGS + ['a'])
  end

  def inner_sanitize(parent, str)
    until str.empty?
      left, tag, str = str.partition(/<\s*(#{ALLOWED_TAGS.join('|')})\s*>(.*?)<\s*\/\1\s*>/)
      parent.add_child Nokogiri::XML::Text.new(left, parent)
      return if tag.empty?
      node = Nokogiri::XML::Node.new($1, parent)
      parent.add_child node
      inner_sanitize(node, $2)
    end
  end

### Retrieve boards ###

  def load(values)
    @message    = values['msg'].to_s.html_safe
    @user_agent = values['ua']
    @user_name  = values['user']
    @user_url   = values['url']
    @created_at = Time.at(values['date'].to_i)
  end

  def self.limit(max, object_type, object_id=nil)
    key = chan_key(object_type, object_id)
    ids = $redis.lrange(key, 0, max-1)
    boards = ids.map do |i|
      vals = $redis.hgetall("boards/msg/#{i}")
      next if vals.nil?
      b = Board.new(object_type: object_type, object_id: object_id)
      b.id = i.to_i
      b.load(vals)
      b
    end
    (class << boards; self; end).send(:define_method, :build) { Board.new(object_type: object_type, object_id: object_id) }
    boards
  end

  def self.all(object_type, object_id=nil)
    limit(0, object_type, object_id)
  end

  def self.last(object_type, object_id=nil)
    limit(1, object_type, object_id).first
  end

### ACL ###

  # Can the given user see messages (and post) on this board?
  def viewable_by?(account)
    return false unless account
    case @object_type
    when Board.news    then news.updatable_by?(account)
    when Board.amr     then account.amr?
    when Board.writing then account.can_post_on_board?
    when Board.free    then true
                       else false
    end
  end

  def creatable_by?(account)
    account.can_post_on_board? && viewable_by?(account)
  end

  def news
    News.find(@object_id) if @object_type == Board.news
  end

  def meta
    if object_type == Board.news
      news
    else
      Board.allocate.tap {|b| b.id = object_type }
    end
  end

### Types ###

  # There are several boards:
  #  * the free one for testing
  #  * the writing board is used for collaborating on the future news
  #  * the AMR board is used by the LinuxFr.org staff
  #  * and one board for each news in moderation.
  TYPES = %w(Free Writing AMR News)

  TYPES.each do |t|
    (class << self; self; end).send(:define_method, t.downcase) { t }
  end
end
