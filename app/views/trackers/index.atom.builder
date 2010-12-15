atom_feed do |feed|
  feed.title("LinuxFr.org : les entrées du suivi")
  feed.updated(@trackers.first.try :created_at)
  feed.icon("/favicon.png")

  @trackers.each do |tracker|
    feed.entry(tracker) do |entry|
      entry.title(tracker.title)
      entry.content(tracker.body, :type => 'html')
      entry.author do |author|
        author.name(tracker.user.name)
      end
    end
  end
end
