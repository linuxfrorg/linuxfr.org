# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://linuxfr.org/"

SitemapGenerator::Sitemap.add_links do |sitemap|
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: sitemap.add path, options
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly', 
  #           :lastmod => Time.now, :host => default_host

  # Static pages
  sitemap.add '/proposer-un-contenu', :priority => 0.5, :changefreq => 'yearly'
  sitemap.add '/contact', :priority => 0.1, :changefreq => 'yearly'
  sitemap.add '/faire_un_don', :priority => 0.5, :changefreq => 'monthly'
  sitemap.add '/team', :priority => 0.5, :changefreq => 'monthly'
  sitemap.add '/informations', :priority => 0.5, :changefreq => 'yearly'
  sitemap.add '/aide', :priority => 0.5, :changefreq => 'monthly'
  sitemap.add '/regles_de_moderation', :priority => 0.5, :changefreq => 'yearly'
  sitemap.add '/code_source_du_site', :priority => 0.5, :changefreq => 'monthly'
  sitemap.add '/plan', :priority => 0.3, :changefreq => 'monthly'

  # News
  sitemap.add sections_path, :priority => 0.6, :changefreq => 'monthly'
  Section.find_each do |section|
    sitemap.add section_path(section), :priority => 0.6, :changefreq => 'daily'
  end
  sitemap.add news_index_path, :priority => 0.7, :changefreq => 'hourly'
  Node.sitemap(News).find_each do |node|
    news = node.content
    sitemap.add news_path(news), :priority => 1.0, :changefreq => news.changefreq, :lastmod => news.lastmod
  end

  # Diaries & Users
  User.find_each do |user|
    sitemap.add user_path(user), :priority => 0.5, :changefreq => 'weekly'
  end
  sitemap.add diaries_path, :priority => 0.6, :changefreq => 'hourly'
  Node.sitemap(Diary).find_each do |node|
    diary = node.content
    next if diary.owner.nil?
    sitemap.add user_diary_path(:user_id => diary.owner, :id => diary), :priority => 0.8, :changefreq => diary.changefreq, :lastmod => diary.lastmod
  end

  # Forums
  sitemap.add forums_path, :priority => 0.3, :changefreq => 'hourly'
  Forum.find_each do |forum|
    sitemap.add forum_path(forum), :priority => 0.3, :changefreq => 'daily'
  end
  Node.sitemap(Post).find_each do |node|
    post = node.content
    sitemap.add forum_post_path(:forum_id => post.forum, :id => post), :priority => 0.5, :changefreq => post.changefreq, :lastmod => post.lastmod
  end

  # Other contents
  sitemap.add polls_path, :priority => 0.3, :changefreq => 'weekly'
  if poll = Poll.current
    sitemap.add poll_path(poll), :priority => 0.5, :changefreq => 'hourly', :lastmod => poll.lastmod
  end
  Poll.archived.includes(:node).find_each do |poll|
    sitemap.add poll_path(poll), :priority => 0.3, :changefreq => 'yearly', :lastmod => poll.lastmod
  end
  sitemap.add trackers_path, :priority => 0.2, :changefreq => 'weekly'
  Node.sitemap(Tracker).find_each do |node|
    tracker = node.content
    sitemap.add tracker_path(tracker), :priority => 0.2, :changefreq => tracker.changefreq, :lastmod => tracker.lastmod
  end
  sitemap.add wiki_pages_path, :priority => 0.8, :changefreq => 'daily'
  Node.sitemap(WikiPage).find_each do |node|
    wiki_page = node.content
    sitemap.add wiki_page_path(wiki_page), :priority => 0.8, :changefreq => wiki_page.changefreq, :lastmod => wiki_page.lastmod
  end

end
