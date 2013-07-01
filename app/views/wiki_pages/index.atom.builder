atom_feed(:root_url => wiki_pages_url, "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/") do |feed|
  feed.title("LinuxFr.org : le wiki")
  feed.updated(@wiki_pages.first.try :updated_at)
  feed.icon("/favicon.png")
  feed.rights("Licence CC by-sa http://creativecommons.org/licenses/by-sa/3.0/deed.fr")

  @wiki_pages.each do |page|
    feed.entry(page) do |entry|
      entry.title(page.title)
      url = wiki_page_url page
      epub = content_tag(:div, link_to("Télécharger ce contenu au format Epub", "#{url}.epub"))
      entry.content(page.body + epub + atom_comments_link(url), :type => 'html')
      entry.author do |author|
        author.name(page.node.user.try :name)
      end
      page.node.popular_tags.each do |tag|
        entry.category(:term => tag.name)
      end
      entry.wfw :commentRss, "http://#{MY_DOMAIN}/nodes/#{page.node.id}/comments.atom"
    end
  end
end
