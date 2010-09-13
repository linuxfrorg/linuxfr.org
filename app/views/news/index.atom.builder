atom_feed do |feed|
  if @user
    feed.title("LinuxFr.org : les dépêches de #{@user.name}")
  else
    feed.title("LinuxFr.org : les dépêches")
  end
  feed.updated(@nodes.first.try :updated_at)

  @nodes.map(&:content).each do |news|
    feed.entry(news) do |entry|
      entry.title(news.title)
      entry.content(news.body, :type => 'html')
      entry.author do |author|
        author.name(news.author_name)
      end
    end
  end
end
