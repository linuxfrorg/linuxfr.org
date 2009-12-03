##
# Some ActiveRecord::Base extensions
#
class ActiveRecord::Base
  def self.wikify_attr(attr, opts={})
    accessor = opts[:as] || attr
    define_method accessor do
      txt = read_attribute(attr)
      return "" if txt.blank?
      wikify txt
    end
  end

  # Transform wiki syntax to HTML
  def wikify(txt, opts={})
    return '' if txt.blank?
    opts = { :base_heading_level => 1, :internal_link_prefix => "http://fr.wikipedia.org/wiki/" }.merge(opts)
    parser = Wikitext::Parser.new(opts)
    ret = parser.parse(txt)
    ret.gsub(/\[BR\]/, '<br/>')
  end
end
