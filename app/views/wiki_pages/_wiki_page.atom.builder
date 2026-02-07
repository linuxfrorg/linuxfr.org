feed.entry(wiki_page) do |entry|
  entry.title(wiki_page.title)
  url = wiki_page_url wiki_page
  epub = content_tag(:div, link_to("Télécharger ce contenu au format EPUB", "#{url}.epub"))
  entry.content(wiki_page.body + epub + atom_comments_link(wiki_page, url), :type => 'html')
  entry.author do |author|
    author.name(wiki_page.node.user.try :name)
  end
  wiki_page.node.popular_tags.each do |tag|
    entry.category(:term => tag.name)
  end
  entry.wfw :commentRss, "#{MY_PUBLIC_URL}/nodes/#{wiki_page.node.id}/comments.atom"
end
