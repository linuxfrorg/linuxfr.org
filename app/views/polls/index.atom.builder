atom_feed do |feed|
  feed.title("LinuxFr.org : les sondages")
  feed.updated(@polls.first.try :created_at)

  @polls.each do |poll|
    feed.entry(poll) do |entry|
      entry.title(poll.title)
      entry.content(poll_body(poll), :type => 'html')
      entry.author do |author|
        author.name(poll.user.public_name)
      end
    end
  end
end
