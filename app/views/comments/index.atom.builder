atom_feed do |feed|
  feed.title("LinuxFr.org : les commentaires pour #{@title || @node.content.title}")
  feed.updated(@comments.last.try :created_at)

  @comments.each do |comment|
    feed.entry(comment, :url => node_comment_url(comment.node, comment)) do |entry|
      entry.title(comment.title)
      entry.content(comment.body, :type => 'html')
      entry.author do |author|
        author.name(comment.user.try :name)
      end
    end
  end
end
