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

  def news_initiated_by(news)
    ( initiated_by(news, news.node.user_id ? nil : news.author_name)
    ).html_safe
  end

  def news_posted_by(news)
    ( posted_by(news, news.node.user_id ? nil : news.author_name) + "\n" +
      edited_by(news) + "\n" +
      moderated_by(news)
    ).html_safe
  end

  def edited_by(news)
    editors = news.edited_by.to_a
    return "" if editors.none?
    users = editors.map {|u| link_to u.name, u }.to_sentence
    caption = content_tag(:span, "Édité par #{content_tag :span, users.html_safe, class: "edited_by"}.".html_safe, class: "edited_by_spanblock");
    caption.html_safe
  end

  def moderated_by(news)
    return "" unless news.moderator_id
    moderator = User.where(id: news.moderator_id).select([:name, :cached_slug]).first
    caption = content_tag(:span, "Modéré par #{link_to moderator.name, moderator}.".html_safe, class: "moderated_by_spanblock");
    caption.html_safe if moderator
  end

  def link_attr(link)
    attrs = { lang: link.lang }
    attrs["data-url"] = edit_redaction_link_path(link) if link.persisted?
    attrs
  end

end
