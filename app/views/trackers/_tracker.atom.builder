feed.entry(tracker) do |entry|
  entry.title("#{tracker.category.title} : #{tracker.title}")
  entry.content(tracker.body + atom_comments_link(tracker_url tracker), :type => 'html')
  entry.author do |author|
    author.name(tracker.user.try(:name) || 'Anonyme')
  end
  entry.category(:term => tracker.category.title)
  tracker.node.popular_tags.each do |tag|
    entry.category(:term => tag.name)
  end
  entry.wfw :commentRss, "https://#{MY_DOMAIN}/nodes/#{tracker.node.id}/comments.atom"
end
