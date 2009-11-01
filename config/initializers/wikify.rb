##
# Define a wikify method
#
class ActiveRecord::Base
  def self.wikify(attr, opts={})
    accessor = opts[:as] || attr
    define_method accessor do
      txt = read_attribute(attr)
      return "" if txt.blank?
      parser = Wikitext::Parser.new(:base_heading_level => 1, :internal_link_prefix => "http://fr.wikipedia.org/wiki/")
      ret = parser.parse(txt)
      ret.gsub(/\[BR\]/, '<br/>')
    end
  end
end

