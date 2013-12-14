# encoding: utf-8
atom_feed(:root_url => trackers_url, "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/") do |feed|
  feed.title("LinuxFr.org : les entrées du suivi")
  feed.updated(@trackers.first.try :created_at)
  feed.icon("/favicon.png")

  render :partial => @trackers, :locals => { :feed => feed }
end
