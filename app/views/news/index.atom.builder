# encoding: utf-8
atom_feed(:root_url => news_index_url, "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/") do |feed|
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
      if news.node.cc_licensed
        entry.rights("Licence CC by-sa http://creativecommons.org/licenses/by-sa/3.0/deed.fr")
      end
      first  = content_tag(:div, news.body)
      links  = content_tag(:ul, news.links.map.with_index do |l,i|
                 content_tag(:li, "lien n°#{i+1} : ".html_safe +
                                  link_to(l.title, "http://#{MY_DOMAIN}/redirect/#{l.id}", :title => l.url, :hreflang => l.lang))
               end.join.html_safe)
      second = content_tag(:div, news.second_part)
      comments = atom_comments_link(news_url news)
      entry.content(first + links + second + comments, :type => 'html')
      entry.author do |author|
        author.name(news.author_name)
      end
      entry.category(:term => news.section.title)
      news.node.popular_tags.each do |tag|
        entry.category(:term => tag.name)
      end
      entry.wfw :commentRss, "http://#{MY_DOMAIN}/nodes/#{news.node.id}/comments.atom"
    end
  end
end
