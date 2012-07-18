# encoding: utf-8
require 'sanitize'

# LinuxFr Flavord Sanitizer
#
class LFSanitizer
  @@sanitizer = Sanitize.new(
    :output => :xhtml,
    :elements => %w(a abbr b blockquote br cite code dd del dfn div dl dt em
                    h1 h2 h3 h4 h5 h6 hr i img ins kbd li mark meter ol p pre
                    q s samp small span strong sub sup table tbody td tfooter
                    th thead tr time ul var video wbr),
    :attributes => {
      :all         => ['data-after', 'data-id', 'id', 'title', 'class'],
      'a'          => ['href', 'name'],
      'blockquote' => ['cite'],
      'img'        => ['alt', 'height', 'src', 'width'],
      'q'          => ['cite'],
      'time'       => ['datetime'],
      'video'      => ['src']
    },
    :protocols => {
      'a'          => {'href' => ['ftp', 'http', 'https', 'irc', 'mailto', 'xmpp', :relative]},
      'blockquote' => {'cite' => ['http', 'https', :relative]},
      'img'        => {'src'  => ['http', 'https', :relative]},
      'q'          => {'cite' => ['http', 'https', :relative]}
    })

  def self.clean(str)
    encode_mb4 @@sanitizer.clean(str)
  end

  MB4_REGEXP = /[^\u{9}-\u{999}]/ 

  def self.encode_mb4(str)
    return str unless str.respond_to?(:encoding)
    str.gsub(MB4_REGEXP) { |c| "&##{c.unpack('U')[0]};" }
  end

end
