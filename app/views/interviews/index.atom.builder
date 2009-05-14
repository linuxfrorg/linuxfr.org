atom_feed do |feed|
  feed.title("LinuxFr.org : les propositions d'entretien")
  feed.updated(@interviews.first.try :created_at)

  @interviews.each do |interview|
    feed.entry(interview) do |entry|
      entry.title(interview.title)
      entry.content(interview.body, :type => 'html')
      entry.author do |author|
        author.name(interview.user.name)
      end
    end
  end
end
