# encoding: UTF-8
module LinkHelper
  def lang_and_hit(link)
    detail = "("
    if link.lang != 'fr'
      detail += "en #{Lang[link.lang].downcase}, "
    end
    detail += "#{pluralize link.nb_clicks, 'clic'})"
  end
end
