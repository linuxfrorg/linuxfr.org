atom_feed(:root_url => comments_latest_url) do |feed|
  feed.title("LinuxFr.org : les derniers commentaires")
  feed.updated(@comments.first.try :created_at)
  feed.icon("/favicon.png")

  @comments.each do |comment|
    feed.entry(comment, :url => "#{url_for_content comment.node.content}#comment-#{comment.id}") do |entry|
      in_response_to = content_tag(:p,
        content_tag(:em,
          "En réponse #{translate_to_content_type comment.content_type} #{link_to comment.node.content.title, path_for_content(comment.node.content)}.".html_safe
        )
      )
      if comment.deleted?
        entry.title("Commentaire supprimé")
        entry.content("#{content_tag(:p, "Commentaire supprimé")} #{in_response_to}", :type => 'html')
      else
        entry.title(comment.title)
        entry.content("#{comment.body} #{in_response_to}", :type => 'html')
      end
      entry.author do |author|
        author.name(comment.user_name)
      end
    end
  end
end
