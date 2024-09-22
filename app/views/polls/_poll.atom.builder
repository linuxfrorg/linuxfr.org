feed.entry(poll, :published => poll.node.created_at) do |entry|
  url = poll_url(poll)
  entry.title(poll.title)
  epub = content_tag(:div, link_to("Télécharger ce contenu au format EPUB", "#{url}.epub"))
  entry.content(poll_body(poll) + epub + atom_comments_link(poll, url), :type => 'html')
  entry.author do |author|
    author.name(poll.node.user.name)
  end
  poll.node.popular_tags.each do |tag|
    entry.category(:term => tag.name)
  end
  entry.wfw :commentRss, "#{MY_PUBLIC_URL}/nodes/#{poll.node.id}/comments.atom"
end
