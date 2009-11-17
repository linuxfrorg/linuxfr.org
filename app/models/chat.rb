##
# The chat is a tornado application used
# for pushing messages to the browsers.
#
class Chat
  @@url = "http://#{MY_DOMAIN}/chat/new"

  attr_accessor :type, :user, :msg, :chan
  
  def self.chan_for(object)
    "#{object.class_name}::#{object.id}"
    # TODO md5sum
  end

  def self.create(&blk)
    chat = new
    yield chat
    chat.post
    chat
  end

  def post
    RestClient.post(@@url, :chan => @chan, :type => @type, :user => @user, :msg => @msg)
  end

end
