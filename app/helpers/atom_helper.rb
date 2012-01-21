# encoding: utf-8
module AtomHelper

  def atom_comments_link(url)
    str = <<-EOS
    <p><a href=\"#{url}#comments\">Lire les commentaires</a></p>
    EOS
    str.html_safe
  end

end
