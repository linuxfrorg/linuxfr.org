atom_feed(:root_url => polls_url, "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/") do |feed|
  feed.title("LinuxFr.org : les sondages")
  feed.updated(@polls.first.try :created_at)
  feed.icon("/favicon.png")

  render :partial => @polls, :locals => { :feed => feed }
end
