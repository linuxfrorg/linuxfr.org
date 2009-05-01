##
# Define a wikify method
#
class ActiveRecord::Base
  def self.wikify(attr, opts={})
    accessor = opts[:as] || attr
    define_method accessor do
      txt = read_attribute(attr)
      return "" if txt.blank?
      parser = Wikitext::Parser.new(:base_heading_level => 2)
      parser.parse(txt)
    end
  end
end

