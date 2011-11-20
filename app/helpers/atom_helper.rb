module AtomHelper

  def atom_comments_link(url)
    <<-EOS
    <p><a href=\"#{url}#comments\">Lire les commentaires</a></p>
    EOS
  end

end
