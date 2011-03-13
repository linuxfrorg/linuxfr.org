atom_feed(:root_url => trackers_url) do |feed|
  feed.title("LinuxFr.org : les commentaires du suivi")
  feed.updated(@comments.last.try :created_at)
  feed.icon("/favicon.png")

  @comments.each do |comment|
    tracker = comment.node.content
    feed.entry(comment, :url => "http://#{MY_DOMAIN}/suivi/#{tracker.to_param}#comment-#{comment.id}") do |entry|
      entry.title("##{tracker.id} : #{comment.title}")
      title = content_tag(:h2, "Entrée du suivi : #{tracker.title}")
      entry.content(title + comment.body, :type => 'html')
      entry.author do |author|
        author.name(comment.user_name)
      end
    end
  end
end
