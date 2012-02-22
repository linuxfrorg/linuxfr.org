# encoding: UTF-8
require "albino"
require "redcarpet"
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
class LFMarkdown < Redcarpet

  def initialize(text, *extensions)
    text            ||= ''
    @filter_styles    = true
    @filter_html      = true
    @autolink         = true
    @tables           = true
    @strikethrough    = true
    @hard_wrap        = true
    @no_intraemphasis = true
    @xhtml            = true
    @generate_toc     = true
    @codemap          = {}
    super(text.dup, *extensions)
  end

  def to_html
    extract_code
    process_internal_wiki_links
    process_wikipedia_links
    ret = fix_heading_levels(super)
    ret = fix_internal_links(ret)
    ret = process_code(ret)
    ret = add_toc_content(ret) if text.length > 5_000
    ret
  end

protected

  LF_LINK_REGEXP = RUBY_VERSION.starts_with?('1.8') ? /\[\[\[([ '\.:\-\w]+)\]\]\]/ : /\[\[\[([ '\.:\-\p{Word}]+)\]\]\]/
  WP_LINK_REGEXP = RUBY_VERSION.starts_with?('1.8') ? /\[\[([ '\.:!\-\(\)\w]+)\]\]/ : /\[\[([ '\.:!\-\(\)\p{Word}]+)\]\]/

  def process_internal_wiki_links
    @text.gsub!(LF_LINK_REGEXP, '[\1](/wiki/\1 "Lien du wiki interne LinuxFr.org")')
  end

  def process_wikipedia_links
    @text.gsub!(WP_LINK_REGEXP) do
      word = $1
      escaped = word.gsub(/\(|\)|'/) {|x| "\\#{x}" }
      tokens = word.split(":")
      if (tokens.length == 2)
        case tokens[0]
          when "en", "es", "eo", "de", "wikt" 
            "[#{tokens[1]}](http://fr.wikipedia.org/wiki/#{escaped} \"Définition Wikipédia\")"
          else
            "[#{word}](http://fr.wikipedia.org/wiki/#{escaped} \"Définition Wikipédia\")"    
        end
      else
        "[#{word}](http://fr.wikipedia.org/wiki/#{escaped} \"Définition Wikipédia\")"
      end
    end
  end

  def fix_heading_levels(str)
    str.gsub!(/<(\/?)h(\d)/) { |_| "<#{$1}h#{$2.to_i + 1}" }
    str
  end

  def fix_internal_links(str)
    str.gsub!(/(href|src)="https:\/\/#{MY_DOMAIN}\//) { |_| "#{$1}=\"http://#{MY_DOMAIN}/" }
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
      output = colorize_code(code, lang)
      data.gsub!(id) { "<pre><code class=\"#{lang}\">#{output}</code></pre>" }
    end
    data
  end

  def colorize_code(code, lang)
    Albino.new(code, lang).colorize(:P => "nowrap").html_safe
  rescue Albino::ShellArgumentError
    raise if lang == "text"
    code = lang + code
    lang = "text"
    retry
  end

  def add_toc_content(str)
    return str if toc_content.blank?
    "<h2 id=\"sommaire\">Sommaire</h2>\n" + toc_content.force_encoding("UTF-8") + str
  end

end
