# encoding: utf-8
atom_feed(:root_url => section_url(@section), "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/") do |feed|
  feed.title("LinuxFr.org : les dépêches de #{@section.title}")
  feed.updated(@news.first.try :updated_at)
  feed.icon("/favicon.png")

  render :partial => @news, :locals => { :feed => feed }
end
