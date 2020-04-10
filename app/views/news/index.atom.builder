# encoding: utf-8
atom_feed(:root_url => news_index_url, "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/") do |feed|
  if @user
    feed.title("LinuxFr.org : les dépêches de #{@user.name}")
  else
    feed.title("LinuxFr.org : les dépêches")
  end
  feed.updated(@nodes.first.try :updated_at)
  feed.icon("/favicon.png")

  render :partial => @nodes.map(&:content), :locals => { :feed => feed }
end
