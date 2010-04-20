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
  sitemap.add submit_anonymous_path, :priority => 0.5, :changefreq => 'yearly'
  sitemap.add '/team', :priority => 0.5, :changefreq => 'monthly'
  sitemap.add '/informations', :priority => 0.5, :changefreq => 'yearly'
  sitemap.add '/plan', :priority => 0.3, :changefreq => 'monthly'
  sitemap.add search_path, :priority => 0.1, :changefreq => 'yealy'
  sitemap.add tags_path, :priority => 0.5, :changefreq => 'daily'

  # News
  sitemap.add sections_path, :priority => 0.6, :changefreq => 'monthly'
  Section.find_each do |section|
    sitemap.add section_path(section), :priority => 0.6, :changefreq => 'daily'
  end
  sitemap.add news_index_path, :priority => 0.7, :changefreq => 'hourly'
  News.published.find_each(:include => [:node]) do |news|
    sitemap.add news_path(news), :priority => 1.0, :changefreq => news.changefreq, :lastmod => news.lastmod
  end

  # Diaries & Users
  User.find_each(:conditions => "role != 'inactive'") do |user|
    sitemap.add user_path(user), :priority => 0.5, :changefreq => 'weekly'
  end
  sitemap.add diaries_path, :priority => 0.6, :changefreq => 'hourly'
  Diary.find_each(:include => [:node]) do |diary|
    sitemap.add user_diary_path(:user_id => diary.user_id, :id => diary.to_param), :priority => 0.8, :changefreq => diary.changefreq, :lastmod => diary.lastmod
  end

  # Forums
  sitemap.add forums_path, :priority => 0.3, :changefreq => 'hourly'
  Forum.find_each do |forum|
    sitemap.add forum_path(forum), :priority => 0.3, :changefreq => 'daily'
  end
  Post.find_each(:include => [:node]) do |post|
    sitemap.add forum_post_path(:forum_id => post.forum_id, :id => post.to_param), :priority => 0.5, :changefreq => post.changefreq, :lastmod => post.lastmod
  end

  # Other contents
  sitemap.add polls_path, :priority => 0.3, :changefreq => 'weekly'
  if poll = Poll.current
    sitemap.add poll_path(poll), :priority => 0.5, :changefreq => 'hourly', :lastmod => poll.lastmod
  end
  Poll.archived.find_each(:include => [:node]) do |poll|
    sitemap.add poll_path(poll), :priority => 0.3, :changefreq => 'yearly', :lastmod => poll.lastmod
  end
  sitemap.add trackers_path, :priority => 0.2, :changefreq => 'weekly'
  Tracker.find_each(:include => [:node]) do |tracker|
    sitemap.add tracker_path(tracker), :priority => 0.2, :changefreq => tracker.changefreq, :lastmod => tracker.lastmod
  end
  sitemap.add wiki_pages_path, :priority => 0.8, :changefreq => 'daily'
  WikiPage.find_each(:include => [:node]) do |wiki_page|
    sitemap.add wiki_page_path(wiki_page), :priority => 0.8, :changefreq => wiki_page.changefreq, :lastmod => wiki_page.lastmod
  end

end
