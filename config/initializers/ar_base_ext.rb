##
# Some ActiveRecord::Base extensions
#
class ActiveRecord::Base
  def self.wikify_attr(attr, opts={})
    method = "wikify_#{attr}".to_sym
    before_validation method
    define_method method do
      send("#{attr}=", wikify(send("wiki_#{attr}"), opts))
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

  def render_to_string(opts)
    ActionView::Base.new(Rails::Configuration.new.view_path).render(opts)
  end
end
