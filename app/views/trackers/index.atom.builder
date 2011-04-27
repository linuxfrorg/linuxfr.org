atom_feed(:root_url => trackers_url, "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/") do |feed|
  feed.title("LinuxFr.org : les entrées du suivi")
  feed.updated(@trackers.first.try :created_at)
  feed.icon("/favicon.png")

  @trackers.each do |tracker|
    feed.entry(tracker) do |entry|
      entry.title("#{tracker.category.title} : #{tracker.title}")
      entry.content(tracker.body, :type => 'html')
      entry.author do |author|
        author.name(tracker.user.try(:name) || 'Anonyme')
      end
      entry.category(:term => tracker.category.title)
      tracker.node.popular_tags.each do |tag|
        entry.category(:term => tag.name)
      end
      entry.wfw :commentRss, "http://#{MY_DOMAIN}/nodes/#{tracker.node.id}/comments.atom"
    end
  end
end
