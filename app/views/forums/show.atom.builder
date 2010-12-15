atom_feed do |feed|
  feed.title("LinuxFr.org : le forum #{@forum.title}")
  feed.updated(@posts.first.try :created_at)
  feed.icon("/favicon.png")

  @posts.each do |post|
    feed.entry([@forum, post]) do |entry|
      entry.title(post.title)
      entry.content(post.body, :type => 'html')
      entry.author do |author|
        author.name(post.user.name)
      end
    end
  end
end
