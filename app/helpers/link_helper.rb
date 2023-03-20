# encoding: UTF-8
module LinkHelper
  def lang_and_hit(link)
    detail = "("
    detail += "en #{Lang[link.lang].downcase}, " unless link.lang == 'fr'
    detail += "#{pluralize link.nb_clicks, 'clic'})"
  end
end
