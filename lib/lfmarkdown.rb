require "rdiscount"

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
    super(text || '', *extensions)
  end

  def to_html
    process_wikipedia_links
    fix_heading_levels(super)
  end

protected

  def process_wikipedia_links
    @text.gsub!(/\[\[(\w+)\]\]/, '[\1](http://fr.wikipedia.org/wiki/\1 "Définition Wikipédia")')
  end

  def fix_heading_levels(str)
    str.gsub!(/<(\/?)h(\d)>/) { |_| "<#{$1}h#{$2.to_i + 1}>" }
    str
  end

end
