atom_feed do |feed|
  feed.title("LinuxFr.org : les commentaires pour #{@user.try(:name) || @feed_for || @node.content.title}")
  feed.updated(@comments.last.try :created_at)
  feed.icon("/favicon.png")

  @comments.each do |comment|
    feed.entry(comment, :url => "/nodes/#{comment.node_id}/comments/#{comment.id}") do |entry|
      entry.title(comment.title)
      entry.content(comment.body, :type => 'html')
      entry.author do |author|
        author.name(comment.user_name)
      end
    end
  end
end
