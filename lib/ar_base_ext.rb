require 'lfmarkdown'
require 'sanitize'

##
# Some ActiveRecord::Base extensions
#
class ActiveRecord::Base
  @@sanitizer = Sanitize.new(
    :output => :xhtml,
    :elements => %w(a abbr b blockquote br cite code dd del dfn div dl dt em
                    h1 h2 h3 h4 h5 h6 hr i img ins kbd li mark meter ol p pre
                    q s samp small span strong sub sup table tbody td tfooter
                    th thead tr time ul var video wbr),
    :attributes => {
      :all         => ['data-after', 'data-id', 'id', 'title', 'class'],
      'a'          => ['href'],
      'blockquote' => ['cite'],
      'img'        => ['alt', 'height', 'src', 'width'],
      'q'          => ['cite'],
      'time'       => ['datetime', 'pubdate'],
      'video'      => ['src']
    },
    :protocols => {
      'a'          => {'href' => ['ftp', 'http', 'https', 'irc', 'mailto', 'xmpp', :relative]},
      'blockquote' => {'cite' => ['http', 'https', :relative]},
      'img'        => {'src'  => ['http', 'https', :relative]},
      'q'          => {'cite' => ['http', 'https', :relative]}
    })

  def self.sanitize_attr(attr)
    method = "sanitize_#{attr}".to_sym
    before_validation method
    define_method method do
      send("#{attr}=", @@sanitizer.clean(self[attr]))
    end
    define_method attr do
      self[attr].to_s.html_safe
    end
  end

  def self.truncate_attr(attr, nb_words=80)
    method = "truncate_#{attr}".to_sym
    before_save method
    define_method method do
      send("truncated_#{attr}=", HTML_Truncator.truncate(send(attr), nb_words, :ellipsis => "[...](suite)")) if send("#{attr}_changed?")
    end
    define_method "truncated_#{attr}" do
      self["truncated_#{attr}"].html_safe
    end
  end

  def self.wikify_attr(attr, *opts)
    method = "wikify_#{attr}".to_sym
    before_validation method
    define_method method do
      send("#{attr}=", wikify(send("wiki_#{attr}"), *opts))
    end
    sanitize_attr attr
  end

  # Transform wiki syntax to HTML
  def wikify(txt, *extensions)
    LFMarkdown.new(txt, *extensions).to_html
  end
end
