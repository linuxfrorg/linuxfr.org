# Inspired from:
#   * http://trueparadox.net/posts/truncating_text_with_html_tags
#   * http://gist.github.com/101410
#
require "nokogiri"

def truncate_html(text, max_words, ellipsis="...")
  doc = Nokogiri::HTML::DocumentFragment.parse(text)
  doc.nb_words > max_words ? doc.truncate(max_words).inner_html + ellipsis : text.to_s
end

module NokogiriTruncator
  module NodeWithChildren
    def truncate(max_words)
      return self if nb_words <= max_words
      truncated_node = self.dup
      truncated_node.children.remove

      self.children.each do |node|
        remaining = max_words - truncated_node.nb_words
        $stderr.puts "****** remaining = #{remaining} ******"
        break if remaining <= 0
        truncated_node.add_child node.truncate(remaining)
      end
      truncated_node
    end

    def nb_words
      inner_text.split.length
    end
  end

  module TextNode
    def truncate(max_words)
      Nokogiri::XML::Text.new(content.split.slice(0, max_words+1).join(' '), parent)
    end
  end
end

Nokogiri::HTML::DocumentFragment.send(:include, NokogiriTruncator::NodeWithChildren)
Nokogiri::XML::Element.send(:include, NokogiriTruncator::NodeWithChildren)
Nokogiri::XML::Text.send(:include, NokogiriTruncator::TextNode)
