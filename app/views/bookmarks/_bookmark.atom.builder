url = polymorphic_url([bookmark.owner, bookmark])
feed.entry(bookmark, :url => url) do |entry|
  entry.title(bookmark.title)
  entry.content("#{link_to bookmark.link, bookmark.link}".html_safe + atom_comments_link(bookmark, url), :type => 'html')
  entry.author do |author|
    author.name(bookmark.owner.name)
  end
  bookmark.node.popular_tags.each do |tag|
    entry.category(:term => tag.name)
  end
  entry.wfw :commentRss, "#{MY_PUBLIC_URL}/nodes/#{bookmark.node.id}/comments.atom"
end
