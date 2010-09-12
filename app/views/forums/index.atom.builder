atom_feed do |feed|
  feed.title("LinuxFr.org : les forums")
  feed.updated(@nodes.first.try :created_at)

  @nodes.each do |node|
    post = node.content
    feed.entry(post, :url => url_for([post.forum, post])) do |entry|
      entry.title(post.title)
      entry.content(post.body, :type => 'html')
      entry.author do |author|
        author.name(post.owner.name)
      end
    end
  end
end
