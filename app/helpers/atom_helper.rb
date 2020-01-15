# encoding: utf-8
module AtomHelper

  def atom_comments_link(content, url)
    str = <<-EOS
    <p>
      <strong>Commentaires :</strong>
      <a href=\"//#{MY_DOMAIN}/nodes/#{content.node.id}/comments.atom\">voir le flux Atom</a>
      <a href=\"#{url}#comments\">ouvrir dans le navigateur</a>
    </p>
    EOS
    str.html_safe
  end

end
