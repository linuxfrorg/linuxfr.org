# encoding: UTF-8
module NewsHelper

  # Build at least 6 links for a news
  # and always add a blank new link,
  # so people without js can add as many links as they want
  # (one new per preview).
  def setup_news(news)
    (news.links.size ... 5).each { news.links.build }
    news.links.build
    news
  end

  def news_posted_by(news)
    (posted_by(news, news.node.user_id ? nil : news.author_name) + moderated_by(news)).html_safe
  end

  def moderated_by(news)
    return "" unless news.moderator_id
    moderator = User.where(:id => news.moderator_id).select([:name, :cached_slug]).first
    " Modéré par #{link_to moderator.name, moderator}.".html_safe if moderator
  end

  def link_attr(link)
    attrs = { :lang => link.lang }
    attrs["data-url"] = edit_redaction_link_path(link) if link.persisted?
    attrs
  end

end
