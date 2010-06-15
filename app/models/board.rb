# It's the famous board, from DaCode (then templeet), boosted to store
# additional messages about redaction & moderation (votes, locks...)
#
class Board
  include Canable::Ables

  NB_MSG_PER_CHAN = 200

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
    @object_type = params[:object_type] || Board.free
    @object_id   = params[:object_id]
    @message     = params[:message]
  end

  def self.create_for(content, attrs={})
    attrs[:object_type] = content.class.name
    attrs[:object_id]   = content.id
    b = Board.new(attrs)
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
    @id = $redis.incr("boards/id")
    @created_at = Time.now
    $redis.hmset("boards/msg/#{@id}", :kind, @kind, :msg, @message, :ua, @user_agent, :user, @user_name, :url, @user_url, :date, @created_at.to_i)
    $redis.lpush(chan_key, @id)
    $redis.lrange(chan_key, NB_MSG_PER_CHAN, -1).each do |i|
      $redis.del "boards/msg/#{i}"
    end
    $redis.ltrim(chan_key, 0, NB_MSG_PER_CHAN - 1)
    # TODO pubsub
    true
  end

### Retrieve boards ###

  def load(values)
    @kind       = values['kind']
    @message    = values['msg']
    @user_agent = values['ua']
    @user_name  = values['user']
    @user_url   = values['url']
    @created_at = Time.at(values['date'].to_i)
  end

  def self.all(object_type, object_id=nil)
    key = chan_key(object_type, object_id)
    ids = $redis.lrange(key, 0, -1)
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
  def viewable_by?(user)
    return false unless user
    case @object_type
    when Board.news:    user.amr?
    when Board.amr:     user.amr?
    when Board.writing: user.can_post_on_board?
    when Board.free:    user.can_post_on_board?
    else                false
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

### Kinds ###

  # A message in a board can be of several kinds.
  # The most common are the 'chat' ones (ie a user chats on a board).
  # But there are also other kinds for more internal usages.
  # For example, locking a paragraph is posted in a board with the 'locking' type.
  KINDS = %w(chat indication vote submission moderation locking creation edition deletion)

### Push to tornado ###

  PUSH_URL = "http://#{MY_DOMAIN}/chat/new"

#   #after_create :push
#   def push
#     id   = self.id
#     key  = private_chan_key
#     av   = ActionView::Base.new(Rails::Configuration.new.view_path)
#     msg  = av.render(:partial => 'boards/board', :locals => {:board => self})
#     Rails.logger.info("Post chat: id=#{id} chan='#{key}' type='#{type}'")
#     #RestClient.post(PUSH_URL, :id => id, :chan => key, :type => type, :msg => msg)
#   rescue
#     nil
#   end
# 
#   def chan
#     "#{object_type}::#{object_id}"
#   end
# 
#   # Public chan key
#   def chan_key
#     Digest::SHA1.hexdigest(private_chan_key)
#   end
# 
#   def private_chan_key
#     # TODO add a secret
#     Digest::SHA1.hexdigest(chan)
#   end

end
