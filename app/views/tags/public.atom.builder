# encoding: utf-8
atom_feed(:root_url => public_tag_url(@tag.name), "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/") do |feed|
  feed.title("LinuxFr.org : les contenus étiquetés avec « #{@tag.name} »")
  feed.updated(@nodes.first.try :updated_at)
  feed.icon("/favicon.png")

  render :partial => @nodes.map(&:content), :locals => { :feed => feed }
end
