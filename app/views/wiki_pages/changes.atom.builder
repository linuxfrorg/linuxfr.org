atom_feed do |feed|
  feed.title("LinuxFr.org : les derniers changements dans le wiki")
  feed.updated(@versions.first.created_at)

  @versions.each do |v|
    feed.entry(v, :url => polymorphic_url(v.wiki_page)) do |entry|
      entry.title("#{v.wiki_page.title} (révision #{v.version})")
      entry.content("#{link_to "Afficher le diff", wiki_page_revision_path(v.wiki_page.friendly_id, v.version)}", :type => 'html')
      entry.author do |author|
        author.name(v.user.try :name)
      end
    end
  end
end
