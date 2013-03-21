# encoding: UTF-8

class Push < Struct.new(:object, :data)

  def self.create(*args)
    Push.new(*args).publish
  end

  def publish
    $redis.publish("b/#{private_key}/#{next_id}", data.to_json)
    self
  end

  def next_id
    $redis.incr("push/id")
  end

### Pubsub keys ###

  class << self
    attr_accessor :secret
  end

  def self.private_key(object)
    Digest::SHA1.hexdigest("#{object.class.name}/#{object.id}/#{secret}")
  end

  def private_key
    self.class.private_key(object)
  end

end
