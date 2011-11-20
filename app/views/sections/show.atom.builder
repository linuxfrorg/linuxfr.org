# encoding: utf-8
atom_feed(:root_url => section_url(@section), "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/") do |feed|
  feed.title("LinuxFr.org : les dépêches de #{@section.title}")
  feed.updated(@news.first.try :updated_at)
  feed.icon("/favicon.png")

  @news.each do |news|
    feed.entry(news) do |entry|
      entry.title(news.title)
      entry.content(news.body + atom_comments_link(url_for news), :type => 'html')
      entry.author do |author|
        author.name(news.author_name)
      end
      entry.wfw :commentRss, "http://#{MY_DOMAIN}/nodes/#{news.node.id}/comments.atom"
    end
  end
end
