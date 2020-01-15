# encoding: utf-8
atom_feed(:root_url => user_url(@user), "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/") do |feed|
  feed.title("LinuxFr.org : les contenus de #{@user.name}")
  feed.updated(@nodes.first.try :updated_at)
  feed.icon("/favicon.png")

  render :partial => @nodes.map(&:content), :locals => { :feed => feed }
end

