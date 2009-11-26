# == Schema Information
#
# Table name: boards
#
#  id          :integer(4)      not null, primary key
#  user_agent  :string(255)
#  type        :string(255)     default("chat"), not null
#  user_id     :integer(4)
#  object_id   :integer(4)
#  object_type :string(255)
#  message     :text
#  created_at  :datetime
#

# It's the famous board, from DaCode (then templeet).
#
class Board < ActiveRecord::Base
  belongs_to :user
  belongs_to :object, :polymorphic => true

  attr_accessible :object_id, :object_type, :message, :user_agent, :user_id

  default_scope :order => 'created_at DESC'
  named_scope :by_kind, lambda { |kind|
    { :include => [:user], :conditions => { :object_type => kind }, :limit => 100 }
  }
  named_scope :old, lambda {
    { :conditions => ["(created_at < ? AND object_type = ?) OR (created_at < ?)",
      DateTime.now - 12.hours, Board.free, DateTime.now - 1.month] }
  }

### Types ###

  # The default for STI is the "type" column, but we do not use this feature.
  def self.inheritance_column
    :nothing
  end

  # A message in a board can be of several types.
  # The most common are the 'chat' ones (ie a user chats on a board).
  # But there are also other types for more internal usages.
  # For example, locking a paragraph is posted in a board with the 'lock' type.
  TYPES = %w(chat indication vote moderation lock)

  TYPES.each do |t|
    named_scope t.to_sym, :conditions => { :type => t }
    self.send(:define_method, "#{t}?") { read_attribute(:type) == t }
  end

### Kinds ###

  # There are several boards:
  #  * the free one for testing
  #  * the writing board is used for collaborating on the future news
  #  * the AMR board is used by the LinuxFr.org staff
  #  * and one board for each news in moderation.
  KINDS = %w(Free Writing AMR News)

  KINDS.each do |k|
    (class << self; self; end).send(:define_method, k.downcase) { k }
  end

  def self.[](kind)
    raise ActiveRecord::RecordNotFound unless KINDS.include?(kind)
    board = Board.new
    board.object_type = kind
    board
  end

### Validation ###

  validates_presence_of :object_type
  validates_presence_of :object_id
  validates_presence_of :user_agent
  validates_presence_of :message

  validates_inclusion_of :object_type, :in => KINDS

### ACL ###

  # Can the given user see messages (and post) on this board?
  def accessible_by?(user)
    return false unless user
    case object_type
    when Board.news:    user.amr?
    when Board.amr:     user.amr?
    when Board.writing: user.can_post_on_board?
    when Board.free:    user.can_post_on_board?
    else                false
    end
  end

### Push to tornado ###

  PUSH_URL = "http://#{MY_DOMAIN}/chat/new"

  after_create :push
  def push
    id   = self.id
    key  = private_chan_key
    av   = ActionView::Base.new(Rails::Configuration.new.view_path)
    msg  = av.render(:partial => 'boards/board', :locals => {:board => self})
    Rails.logger.info("Post chat: id=#{id} chan='#{key}' type='#{type}'")
    RestClient.post(PUSH_URL, :id => id, :chan => key, :type => type, :msg => msg)
  rescue
    nil
  end

  def chan
    "#{object_type}::#{object_id}"
  end

  # Public chan key
  def chan_key
    Digest::SHA1.hexdigest(private_chan_key)
  end

  def private_chan_key
    # TODO add a secret
    Digest::SHA1.hexdigest(chan)
  end

end
