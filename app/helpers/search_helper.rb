# encoding: utf-8
module SearchHelper
  def es_facet_to_class(type)
    type.capitalize.sub("Wikipage", "WikiPage").constantize
  end
end
