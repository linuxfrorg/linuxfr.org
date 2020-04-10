url = forum_post_url(:forum_id => post.forum, :id => post)
feed.entry(post, :url => url) do |entry|
  entry.title(post.title)
  epub = content_tag(:div, link_to("Télécharger ce contenu au format EPUB", "#{url}.epub"))
  entry.content(post.body + epub + atom_comments_link(post, url), :type => 'html')
  entry.author do |author|
    author.name(post.user.name)
  end
  entry.category(:term => post.forum.title)
  post.node.popular_tags.each do |tag|
    entry.category(:term => tag.name)
  end
  entry.wfw :commentRss, "https://#{MY_DOMAIN}/nodes/#{post.node.id}/comments.atom"
end
