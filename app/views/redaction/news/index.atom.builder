# encoding: utf-8
atom_feed(:root_url => redaction_news_index_url) do |feed|
  feed.title("LinuxFr.org : les dépêches en cours de rédaction")
  feed.updated(@news.first.try :updated_at)
  feed.icon("/favicon.png")

  @news.each do |news|
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
      comments = atom_comments_link(redaction_news_url news)
      entry.content(first + links + second + comments, :type => 'html')
      entry.author do |author|
        author.name(news.author_name)
      end
      entry.category(:term => news.section.title)
      news.node.popular_tags.each do |tag|
        entry.category(:term => tag.name)
      end
    end
  end
end
