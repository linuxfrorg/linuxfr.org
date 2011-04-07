# LinuxFr Flavored Truncator
#
class LFTruncator < HTML_Truncator
  DEFAULT_OPTIONS = { :ellipsis => "[...](suite)", :length_in_chars => false }

  def self.truncate(text, max, opts={})
    opts = DEFAULT_OPTIONS.merge(opts)
    doc = Nokogiri::HTML::DocumentFragment.parse(text)
    doc.search("img").remove
    doc.truncate(max, opts).first
  end

end
