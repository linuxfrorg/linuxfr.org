# encoding: utf-8
require 'html/pipeline'
require 'lftruncator'

HTML::Pipeline::LinuxFr::CONTEXT[:host] = MY_DOMAIN

##
# Some ActiveRecord::Base extensions
#
class ActiveRecord::Base
  def self.sanitize_attr(attr)
    method = "sanitize_#{attr}".to_sym
    before_validation method
    define_method method do
      send("#{attr}=", HTML::Pipeline::LinuxFr.sanitize(self[attr])) unless self[attr].html_safe?
    end
    mark_as_safe_attr attr
  end

  def self.truncate_attr(attr, nb_words=80)
    method = "truncate_#{attr}".to_sym
    before_save method
    define_method method do
      return unless send("#{attr}_changed?")
      send("truncated_#{attr}=", LFTruncator.truncate(send(attr), nb_words))
    end
    mark_as_safe_attr "truncated_#{attr}"
  end

  def self.wikify_attr(attr)
    method = "wikify_#{attr}".to_sym
    before_validation method
    define_method method do
      send("#{attr}=", wikify(send "wiki_#{attr}"))
    end
    mark_as_safe_attr attr
  end

  def self.mark_as_safe_attr(attr)
    define_method attr do
      self[attr].to_s.html_safe
    end
  end

  # Transform wiki syntax to HTML
  def wikify(txt)
    HTML::Pipeline::LinuxFr.render txt
  end

  # Extract the Table of contents from this html
  def toc_for(html)
    doc = Nokogiri::HTML::DocumentFragment.parse html
    doc.css(".sommaire,.toc,#sommaire,#sommaire+ul").to_html.html_safe
  end

  # Transform []() to links on the given text
  def linkify(txt)
    ERB::Util.h(txt).gsub(/\[([^\]]*)\]\(([^)]*)\)/, '<a href="\2">\1</a>').html_safe
  end
end
