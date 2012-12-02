atom_feed(:root_url => wiki_pages_url, "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/") do |feed|
  feed.title("LinuxFr.org : le wiki")
  feed.updated(@wiki_pages.first.try :updated_at)
  feed.icon("/favicon.png")
  feed.rights("Licence CC by-sa http://creativecommons.org/licenses/by-sa/3.0/deed.fr")

  @wiki_pages.each do |page|
    feed.entry(page) do |entry|
      entry.title(page.title)
      entry.content(page.body + atom_comments_link(wiki_page_url page), :type => 'html')
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
