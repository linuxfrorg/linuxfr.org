atom_feed(:root_url => section_url(@section)) do |feed|
  feed.title("LinuxFr.org : les dépêches de #{@section.title}")
  feed.updated(@news.first.try :updated_at)
  feed.icon("/favicon.png")

  @news.each do |news|
    feed.entry(news) do |entry|
      entry.title(news.title)
      entry.content(news.body, :type => 'html')
      entry.author do |author|
        author.name(news.user.name)
      end
    end
  end
end
