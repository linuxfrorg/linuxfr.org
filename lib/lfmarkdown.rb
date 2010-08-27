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
    @filter_styles = true
    @filter_html   = true
    @autolink      = true
    @codemap       = {}
    text         ||= ''
    super(text.dup, *extensions)
  end

  def to_html
    process_wikipedia_links
    extract_code
    ret = fix_heading_levels(super)
    process_code(ret)
  end

protected

  def process_wikipedia_links
    @text.gsub!(/\[\[(\w+)\]\]/, '[\1](http://fr.wikipedia.org/wiki/\1 "Définition Wikipédia")')
  end

  def fix_heading_levels(str)
    str.gsub!(/<(\/?)h(\d)>/) { |_| "<#{$1}h#{$2.to_i + 1}>" }
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
      if code.lines.all? { |line| line =~ /\A\r?\n\Z/ || line =~ /^(  |\t)/ }
        code.gsub!(/^(  |\t)/m, '')
      end
      Rails.logger.info "*** albino bin: #{Albino.bin}"
      Rails.logger.info "*** albino: #{Albino.new(code, lang).colorize} ***"
      data.gsub!(id, Albino.new(code, lang).colorize)
    end
    data
  end
end
