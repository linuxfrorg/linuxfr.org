require 'digest/sha1'

##
# The chat is a tornado application used
# for pushing messages to the browsers.
#
class Chat < Struct.new(:id, :chan, :type, :msg)
  @@url = "http://#{MY_DOMAIN}/chat/new"
  
  def self.create(*attrs, &blk)
    chat = new(*attrs)
    yield chat if block_given?
    chat.post
    chat
  end

  def post
    key = self.class.private_chan_key(chan)
    Rails.logger.info("Post chat: id=#{id} chan='#{key}' type='#{type}'")
    RestClient.post(@@url, :id => id, :chan => key, :type => type, :msg => msg)
  rescue
    nil
  end

  def self.public_chan_key(str)
    key = private_chan_key(str)
    Digest::SHA1.hexdigest(key)
  end

  def self.private_chan_key(str)
    # TODO add a secret
    Digest::SHA1.hexdigest(str)
  end

end
