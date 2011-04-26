atom_feed(:root_url => diaries_url, "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/") do |feed|
  if @user
    feed.title("LinuxFr.org : les journaux de #{@user.name}")
  else
    feed.title("LinuxFr.org : les journaux")
  end
  feed.updated(@nodes.first.try :created_at)
  feed.icon("/favicon.png")

  @nodes.map(&:content).each do |diary|
    feed.entry(diary, :url => polymorphic_url([diary.owner, diary])) do |entry|
      entry.title(diary.title)
      entry.content(diary.body, :type => 'html')
      entry.author do |author|
        author.name(diary.owner.name)
      end
      diary.node.popular_tags.each do |tag|
        entry.category(:term => tag.name)
      end
      entry.wfw :commentRss, "http://#{MY_DOMAIN}/nodes/#{diary.node.id}/comments.atom"
    end
  end
end
