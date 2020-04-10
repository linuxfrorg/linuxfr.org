atom_feed(:root_url => diaries_url, "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/") do |feed|
  if @user
    feed.title("LinuxFr.org : les journaux de #{@user.name}")
  else
    feed.title("LinuxFr.org : les journaux")
  end
  feed.updated(@nodes.first.try :created_at)
  feed.icon("/favicon.png")

  render :partial => @nodes.map(&:content), :locals => { :feed => feed }
end
