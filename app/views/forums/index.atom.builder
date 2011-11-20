atom_feed(:root_url => forums_url, "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/") do |feed|
  if @user
    feed.title("LinuxFr.org : les posts de #{@user.name}")
  else
    feed.title("LinuxFr.org : les forums")
  end
  feed.updated(@nodes.first.try :created_at)
  feed.icon("/favicon.png")

  @nodes.each do |node|
    post = node.content
    url  = forum_post_url(:forum_id => post.forum, :id => post)
    feed.entry(post, :url => url) do |entry|
      entry.title(post.title)
      entry.content(post.body + atom_comments_link(url), :type => 'html')
      entry.author do |author|
        author.name(post.user.name)
      end
      entry.category(:term => post.forum.title)
      node.popular_tags.each do |tag|
        entry.category(:term => tag.name)
      end
      entry.wfw :commentRss, "http://#{MY_DOMAIN}/nodes/#{node.id}/comments.atom"
    end
  end
end
