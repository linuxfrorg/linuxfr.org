atom_feed do |feed|
  if @user
    feed.title("LinuxFr.org : les journaux de #{@user.name}")
  else
    feed.title("LinuxFr.org : les journaux")
  end
  feed.updated(@nodes.first.try :created_at)

  @nodes.map(&:content).each do |diary|
    feed.entry(diary, :url => polymorphic_url([diary.owner, diary])) do |entry|
      entry.title(diary.title)
      entry.content(diary.body, :type => 'html')
      entry.author do |author|
        author.name(diary.owner.name)
      end
    end
  end
end
