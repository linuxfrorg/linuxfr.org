atom_feed do |feed|
  feed.title("LinuxFr.org : les entrées du suivi")
  feed.updated(@trackers.first.created_at)

  @trackers.each do |tracker|
    feed.entry(tracker) do |entry|
      entry.title(tracker.title)
      entry.content(tracker.body, :type => 'html')
      entry.author do |author|
        author.name(tracker.user.public_name)
      end
    end
  end
end
