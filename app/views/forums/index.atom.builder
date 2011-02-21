atom_feed do |feed|
  if @user
    feed.title("LinuxFr.org : les posts de #{@user.name}")
  else
    feed.title("LinuxFr.org : les forums")
  end
  feed.updated(@nodes.first.try :created_at)
  feed.icon("/favicon.png")

  @nodes.each do |node|
    post = node.content
    feed.entry(post, :url => forum_post_url(:forum_id => post.forum, :id => post)) do |entry|
      entry.title(post.title)
      entry.content(post.body, :type => 'html')
      entry.author do |author|
        author.name(post.user.name)
      end
    end
  end
end
