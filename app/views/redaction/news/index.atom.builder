# encoding: utf-8
atom_feed(:root_url => redaction_news_index_url) do |feed|
  feed.title("LinuxFr.org : les dépêches en cours de rédaction")
  feed.updated(@news.first.try :updated_at)
  feed.icon("/favicon.png")

  render :partial => @news, :locals => { :feed => feed }
end
