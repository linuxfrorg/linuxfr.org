# encoding: UTF-8
require "rdiscount"
require "digest/sha1"

# LinuxFr Flavored Markdown
#
# LinuxFr used markdown as its wiki syntax, but with some differences with the
# standard markdown:
#  * the heading levels for titles range from `<h2>` to `<h5>`
#  * `[[Foobar]]` is transformed to a link to wikipedia (http://fr.wikipedia.org/wiki/Foobar)
#  * URL are automatically transformed in links
#  * words with several underscores are left unchanged (no italics)
#  * PHP Markdown Extra-style tables are supported
#  * and some other extensions listed on http://www.pell.portland.or.us/~orc/Code/discount/#Language+extensions
#
class LFMarkdown < Markdown

  def initialize(text, *extensions)
    text         ||= ''
    @filter_styles = true
    @filter_html   = true
    @autolink      = true
    @codemap       = {}
    @generate_toc  = text.length > 12_000
    super(text.dup, *extensions)
  end

  def to_html
    extract_code
    process_wikipedia_links
    process_newlines
    ret = fix_heading_levels(super)
    ret = process_code(ret)
    ret = add_toc_content(ret) if @generate_toc
    ret
  end

protected

  WP_LINK_REGEXP = RUBY_VERSION.starts_with?('1.8') ? /\[\[([ \.:\-\w]+)\]\]/ : /\[\[([ \.:\-\p{Word}]+)\]\]/

  def process_wikipedia_links
    @text.gsub!(WP_LINK_REGEXP, '[\1](http://fr.wikipedia.org/wiki/\1 "Définition Wikipédia")')
  end

  # Code taken from http://github.com/github-flavored-markdown/
  def process_newlines
    @text.gsub!("\r", "")
    @text.gsub!(/(\A|^$\n)(^\w[^\n]*\n)(^\w[^\n]*$)+/m) do |x|
      x.gsub(/^(.+)$/, "\\1  ")
    end
  end

  def fix_heading_levels(str)
    str.gsub!(/<(\/?)h(\d)/) { |_| "<#{$1}h#{$2.to_i + 1}" }
    str
  end

  # Code taken from gollum (http://github.com/github/gollum)
  def extract_code
    @text.gsub!(/^``` ?(.+?)\r?\n(.+?)\r?\n```\r?$/m) do
      id = Digest::SHA1.hexdigest($2)
      @codemap[id] = { :lang => $1, :code => $2 }
      id
    end
  end

  def process_code(data)
    @codemap.each do |id, spec|
      lang, code = spec[:lang], spec[:code]
      if code.lines.all? { |line| line =~ /\A\r?\n\Z/ || line =~ /^(    |\t)/ }
        code.gsub!(/^(    |\t)/m, '')
      end
      output = Albino.new(code, lang).colorize(:P => "nowrap")
      data.gsub!(id, "<pre><code class=\"#{lang}\">#{output}</code></pre>")
    end
    data
  end

  def add_toc_content(str)
    return str if toc_content.blank?
    "<h2 id=\"sommaire\">Sommaire</h2>\n" + toc_content.force_encoding("UTF-8") + str
  end

end
