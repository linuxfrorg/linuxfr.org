# encoding: utf-8
module SearchHelper
  def es_type(type)
    type.singularize.camelize.constantize.type
  end
end
