atom_feed(:root_url => forum_url(@forum), :language => "fr_FR", "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/") do |feed|
  feed.title("LinuxFr.org : le forum #{@forum.title}")
  feed.updated(@posts.first.try :created_at)
  feed.icon("/favicon.png")

  render :partial => @posts, :locals => { :feed => feed }
end
