# encoding: UTF-8

##
# When a user use an image from an external domain on LinuxFr.org, we keep some
# infos about this image in redis, so it can served by our proxy/cache daemon, img.
#
class Image < Struct.new(:link, :title, :alt_text, :blocked)
  LATEST_KEY = "img/latest"
  NB_IMG_IN_LATEST = 100
  BLOCKED_KEY = "img/blocked"
  E403 = "/images/403.png"

  def self.latest(nb=NB_IMG_IN_LATEST)
    links = $redis.lrange LATEST_KEY, 0, nb
    links.map {|l| Image.new(l, l, l, ($redis.hget "img/#{l}", "status") == "Blocked") }
  end

  def self.blocked(nb)
    links = $redis.lrange BLOCKED_KEY, 0, nb
    links.map {|l| Image.new(l, l, l, ($redis.hget "img/#{l}", "status") == "Blocked") }
  end

  def self.decoded_link(encoded_link)
    [encoded_link].pack('H*')
  end

  def self.destroy(encoded_link)
    link = decoded_link(encoded_link)
    if $redis.hset "img/#{link}", "status", "Blocked"
      $redis.lpush BLOCKED_KEY, link
    end
  end

  def self.original_link(link)
    decoded_link link.split('/')[-2]
  end

  def register_in_redis
    if $redis.exists "img/#{link}"
      $redis.del "img/err/#{link}"
      return
    end
    $redis.hsetnx "img/#{link}", "created_at", Time.now.to_i
    $redis.lpush LATEST_KEY, link
    $redis.ltrim LATEST_KEY, 0, NB_IMG_IN_LATEST - 1
  end

  def internal_link?
    uri = URI.parse(URI.encode link)
    !uri.host || uri.host == MY_DOMAIN || uri.host == IMG_DOMAIN
  rescue
    true
  end

  def blacklisted?
    uri = URI.parse(URI.encode link)
    uri.host =~ /^(10|127|169\.254|192\.168)\./
  end

  def encoded_link
    link.unpack('H*').first
  end

  def filename
    File.basename link
  end

  def src(type="img")
    return link if internal_link?
    return E403 if blacklisted?
    register_in_redis
    "//#{IMG_DOMAIN}/#{type}/#{encoded_link}/#{filename}"
  end

  def src_attr
    "src=\"#{CGI.escapeHTML src.to_s}\""
  end

  def alt_attr
    "alt=\"#{CGI.escapeHTML alt_text.to_s}\""
  end

  def title_attr
    parts = [title]
    parts << "Source : #{link}" unless internal_link?
    parts.compact!
    parts.empty? ? "" : "title=\"#{CGI.escapeHTML parts.join(' | ')}\" "
  end

  def to_html
    "<img #{src_attr} #{alt_attr} #{title_attr}/>"
  end

end
