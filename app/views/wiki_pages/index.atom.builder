atom_feed(:root_url => wiki_pages_url, "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/") do |feed|
  feed.title("LinuxFr.org : le wiki")
  feed.updated(@wiki_pages.first.try :updated_at)
  feed.icon("/favicon.png")
  feed.rights("Licence CC by-sa http://creativecommons.org/licenses/by-sa/4.0/deed.fr")

  render :partial => @wiki_pages, :locals => { :feed => feed }
end
