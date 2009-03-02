atom_feed do |feed|
  feed.title("LinuxFr.org : le wiki")
  feed.updated(@wiki_pages.first.try :updated_at)

  @wiki_pages.each do |page|
    feed.entry(page) do |entry|
      entry.title(page.title)
      entry.content(page.wikified_body, :type => 'html')
      entry.author do |author|
        author.name(page.user.public_name)
      end
    end
  end
end
