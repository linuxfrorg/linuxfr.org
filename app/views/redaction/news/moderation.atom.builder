# encoding: utf-8
atom_feed(:root_url => moderation_redaction_news_index_url) do |feed|
  feed.title("LinuxFr.org : les dépêches en cours de modération")
  feed.updated(@news.first.try :updated_at)
  feed.icon("/favicon.png")

  @news.each do |news|
    feed.entry(news, :published => news.node.created_at, :url => redaction_url) do |entry|
      entry.title(news.title)
      if news.node.cc_licensed
        entry.rights("Licence CC by-sa http://creativecommons.org/licenses/by-sa/4.0/deed.fr")
      end
      entry.content(" ", :type => 'html')
      entry.author do |author|
        author.name(news.author_name)
      end
      entry.category(:term => news.section.title)
    end
  end
end
