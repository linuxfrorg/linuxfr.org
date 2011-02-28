atom_feed(:root_url => news_index_url) do |feed|
  if @user
    feed.title("LinuxFr.org : les dépêches de #{@user.name}")
  else
    feed.title("LinuxFr.org : les dépêches")
  end
  feed.updated(@nodes.first.try :updated_at)
  feed.icon("/favicon.png")

  @nodes.map(&:content).each do |news|
    feed.entry(news, :published => news.node.created_at) do |entry|
      entry.title(news.title)
      first  = content_tag(:div, news.body)
      links  = content_tag(:ul, news.links.map.with_index do |l,i|
                 content_tag(:li, "lien n°#{i+1} : ".html_safe + link_to(l.title, l.url))
               end.join.html_safe)
      second = content_tag(:div, news.second_part)
      entry.content(first + links + second, :type => 'html')
      entry.author do |author|
        author.name(news.author_name)
      end
    end
  end
end
