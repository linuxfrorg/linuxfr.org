# encoding: utf-8
class Lang
  def self.all
    keys = $redis.lrange("lang", 0, -1)
    return [] if keys.empty?
    full = keys.map {|k| "lang/#{k}" }
    vals = $redis.mget(*full)
    vals.zip(keys)
  end

  def self.[]=(key, value)
    $redis.set("lang/#{key}", value)
    $redis.rpush("lang", key)
  end
end
