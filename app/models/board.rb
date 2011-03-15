# It's the famous board, from DaCode (then templeet), boosted to store
# additional messages about redaction & moderation (votes, locks...)
#
class Board
  include Canable::Ables

  NB_MSG_PER_CHAN = 100

### Constructors and attributes ###

  attr_accessor :id, :kind, :user_name, :user_url, :user_agent
  attr_accessor :object_type, :object_id, :message, :created_at

  def user=(user)
    if user.respond_to?(:account)
      @user_name = user.account.login
      @user_url  = "/users/#{user.to_param}"
    else
      @user_name = user
    end
  end

  def user_link
    (@user_url.blank? ? @user_name : "<a href=\"#{@user_url}\">#{@user_name}</a>").html_safe
  end

  def initialize(params={})
    @kind        = "chat"
    @object_type = Board.free
    @object_type = params[:object_type] unless params[:object_type].blank?
    @object_id   = params[:object_id]   unless params[:object_id].blank?
    @message     = params[:message]
  end

  def self.create_for(content, attrs={})
    b = Board.new
    b.object_type = content.class.name
    b.object_id   = content.id
    b.message = attrs[:message].html_safe
    b.user = attrs[:user]
    b.kind = attrs[:kind]
    b.save
    b
  end

### Save boards ###

  def self.chan_key(object_type, object_id)
    ["boards/chans",  object_type.downcase, object_id].compact.join('/')
  end

  def chan_key
    self.class.chan_key(@object_type, @object_id)
  end

  def save
    return false if @message.blank?
    sanitize_message unless @message.html_safe?
    @id = $redis.incr("boards/id")
    @created_at = Time.now
    $redis.hmset("boards/msg/#{@id}", :kind, @kind, :msg, @message, :ua, @user_agent, :user, @user_name, :url, @user_url, :date, @created_at.to_i)
    $redis.lpush(chan_key, @id)
    $redis.lrange(chan_key, NB_MSG_PER_CHAN, -1).each do |i|
      $redis.del "boards/msg/#{i}"
    end
    $redis.ltrim(chan_key, 0, NB_MSG_PER_CHAN - 1)
    $redis.publish("b/#{private_key}/#{@id}/#{@kind}", rendered)
    true
  end

  def rendered
    BoardsController.new.render_to_string(:partial => "board", :locals => {:board => self})
  end

### Sanitizing messages ###

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  def sanitize_message
    doc = Nokogiri::HTML::Document.new
    doc.encoding = "utf-8"
    node = Nokogiri::HTML::DocumentFragment.new(doc)
    inner_sanitize(node, @message[0, 500])
    @message = auto_link(node.to_s, :urls) { "[url]" }
  end

  def inner_sanitize(parent, str)
    until str.empty?
      left, tag, str = str.partition(/<\s*(b|i|u|s|strong|em|code)\s*>(.*?)<\s*\/\1\s*>/)
      parent.add_child Nokogiri::XML::Text.new(left, parent)
      return if tag.empty?
      node = Nokogiri::XML::Node.new($1, parent)
      parent.add_child node
      inner_sanitize(node, $2)
    end
  end

### Pubsub keys ###

  class << self
    attr_accessor :secret
  end

  def private_key
    Digest::SHA1.hexdigest("#{@object_type}/#{@object_id}/#{self.class.secret}")
  end

### Retrieve boards ###

  def load(values)
    @kind       = values['kind']
    @message    = values['msg'].to_s.html_safe
    @user_agent = values['ua']
    @user_name  = values['user']
    @user_url   = values['url']
    @created_at = Time.at(values['date'].to_i)
  end

  def self.all(object_type, object_id=nil)
    limit(0, object_type, object_id)
  end

  def self.last(object_type, object_id=nil)
    limit(1, object_type, object_id).first
  end

  def self.limit(max, object_type, object_id=nil)
    key = chan_key(object_type, object_id)
    ids = $redis.lrange(key, 0, max-1)
    boards = []
    ids.each do |i|
      vals = $redis.hgetall("boards/msg/#{i}")
      next if vals.nil?
      b = Board.new
      b.id = i.to_i
      b.load(vals)
      boards << b
    end
    (class << boards; self; end).send(:define_method, :build) { Board.new(:object_type => object_type, :object_id => object_id) }
    boards
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

### Kinds ###

  # A message in a board can be of several kinds.
  # The most common are the 'chat' ones (ie a user chats on a board).
  # But there are also other kinds for more internal usages.
  # For example, locking a paragraph is posted in a board with the 'locking' type.
  KINDS = %w(chat indication vote submission moderation locking creation edition deletion)

### ActiveModel ###

  extend  ActiveModel::Naming
  include ActiveModel::Conversion

  def valid?()     true  end
  def persisted?() !!@id end

  def errors
    obj = Object.new
    def obj.[](key)         [] end
    def obj.full_messages() [] end
    obj
  end
end
