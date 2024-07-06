# encoding: utf-8
module ApplicationHelper

  def title(title, tag=nil)
    title = h(title)
    @title.unshift title
    content_tag(tag, title) if tag
  end

  def h1(str)
    title(str, :h1)
  end

  def feed(title, link=nil)
    link ||= { format: :atom }
    @feeds[link] = title
  end

  def link(rel, link)
    @links[link] = rel
  end

  def meta_for(content)
    @author      = content.node.user.try(:name)
    @keywords    = content.node.popular_tags.map &:name
    @description = content.title
    @dont_index  = true if content.node.score < 0
    published_at = content.node.try(:created_at) || DateTime.now()
    # For all content recently published, ask robots to not index it if
    # a minimum score is not reached during the first 24 hours.
    # The threshold is set to the one used by moderated News, so the moderated
    # content can still be fastly indexed by robots.
    @dont_index ||= true if published_at > DateTime.now() - 24.hour && content.node.score <= News.accept_threshold
  end

end
