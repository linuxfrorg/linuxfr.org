require 'lfmarkdown'

##
# Some ActiveRecord::Base extensions
#
class ActiveRecord::Base
  def self.truncate_attr(attr, nb_words=80)
    method = "truncate_#{attr}".to_sym
    before_save method
    define_method method do
      send("truncated_#{attr}=", HTML_Truncator.truncate(send(attr), nb_words, :ellipsis => "[...](suite)")) if send("#{attr}_changed?")
    end
  end

  def self.wikify_attr(attr, *opts)
    method = "wikify_#{attr}".to_sym
    before_validation method
    define_method method do
      send("#{attr}=", wikify(send("wiki_#{attr}"), *opts))
    end
  end

  # Transform wiki syntax to HTML
  def wikify(txt, *extensions)
    LFMarkdown.new(txt, *extensions).to_html
  end
end
