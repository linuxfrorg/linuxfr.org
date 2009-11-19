require 'digest/sha1'

##
# The chat is a tornado application used
# for pushing messages to the browsers.
#
class Chat < Struct.new(:id, :chan, :msg)
  @@url = "http://#{MY_DOMAIN}/chat/new"
  
  def self.create(*attrs, &blk)
    chat = new(*attrs)
    yield chat if block_given?
    chat.post
    chat
  end

  def post
    # TODO add a secret
    chan = Digest::SHA1.hexdigest(self.chan)
    RestClient.post(@@url, :id => self.id, :chan => chan, :msg => self.msg)
  end

end
