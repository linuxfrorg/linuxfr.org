# encoding: UTF-8

##
# When a user use an image from an external domain on LinuxFr.org, we keep some
# infos about this image in redis, so it can served by our proxy/cache daemon, img.
#
class Image < Struct.new(:link, :title, :alt_text)
  LATEST_KEY = "img/latest"
  NB_IMG_IN_LATEST = 100
  E403 = "/images/403.png"

  def self.latest(nb=NB_IMG_IN_LATEST)
    links = $redis.lrange LATEST_KEY, 0, nb
    links.map {|l| Image.new(l, l, l) }
  end

  def self.decoded_link(encoded_link)
    [encoded_link].pack('H*')
  end

  def self.destroy(encoded_link)
    $redis.hset "img/#{decoded_link encoded_link}", "status", "Blocked"
  end

  def self.original_link(link)
    decoded_link link.split('/')[-2]
  end

  def register_in_redis
    return if $redis.exists "img/#{link}"
    $redis.hsetnx "img/#{link}", "created_at", Time.now.to_i
    $redis.lpush LATEST_KEY, link
    $redis.ltrim LATEST_KEY, 0, NB_IMG_IN_LATEST - 1
  end

  def internal_link?
    uri = URI.parse(link)
    !uri.host || uri.host == MY_DOMAIN || uri.host == IMG_DOMAIN
  end

  def blacklisted?
    uri = URI.parse(link)
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
    "src=\"#{CGI.escapeHTML src}\""
  end

  def alt_attr
    "alt=\"#{CGI.escapeHTML alt_text}\""
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
