atom_feed do |feed|
  feed.title("LinuxFr.org : les journaux")
  feed.updated(@diaries.first.created_at)

  @diaries.each do |diary|
    feed.entry(diary) do |entry|
      entry.title(diary.title)
      entry.content(diary.body, :type => 'html')
      entry.author do |author|
        author.name(diary.user.public_name)
      end
    end
  end
end
