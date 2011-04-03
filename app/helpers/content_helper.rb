module ContentHelper

  def spellcheck(html)
    HTML_Spellchecker.french.spellcheck(html).html_safe
  end

end
