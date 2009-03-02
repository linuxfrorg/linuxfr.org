atom_feed do |feed|
  feed.title("LinuxFr.org : les dépêches")
  feed.updated(@news.first.try :updated_at)

  @news.each do |news|
    feed.entry(news) do |entry|
      entry.title(news.title)
      entry.content(news.wikified_body, :type => 'html')
      entry.author do |author|
        author.name(news.user.public_name)
      end
    end
  end
end
