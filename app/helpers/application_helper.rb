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
    @userid      = content.node.user.try(:login)
    @topic       = content.title
    @description = description_for(content)
    @url         = url_for_content(content)
    @keywords    = content.node.popular_tags.map &:name
    @dont_index  = true if content.node.score < 0
    published_at = content.node.try(:created_at) || DateTime.now()
    # For all content recently published, ask robots to not index it if
    # a minimum score is not reached during the first 24 hours.
    # The threshold is set to the one used by moderated News, so the moderated
    # content can still be fastly indexed by robots.
    @dont_index ||= true if published_at > DateTime.now() - 24.hour && content.node.score <= News.accept_threshold

    # Use the article type and extract the first image for News and Diary.
    # Use the default type and logo for everything else.
    if content.is_a?(News) || content.is_a?(Diary)
      @type       = "article"
      @image_data = image_data_for(content)
      @image      = @image_data[:src]
      @image_alt  = @image_data[:alt]
      if content.is_a?(News)
         @section = content.section.try(:title)
      end
    end
  end

  def description_for(content)
    description =
      case content
      when News
        content.body
      when Diary, Post, Tracker, WikiPage
        content.truncated_body.presence || content.body
      when Poll
        content.explanations.presence || content.title
      else
        content.title
      end

    truncate(strip_tags(description.to_s).gsub(/\s+/, " ").strip, length: 300)
  end

  def image_data_for(content)
    html =
      case content
      when News
        [content.body, content.second_part].compact.join("\n")
      when Diary
        content.body.to_s
      end

    return { src: Logo.default_image, alt: content.title } if html.blank?

    # Find the first image in the article.
    image = Nokogiri::HTML::DocumentFragment
      .parse(html)
      .at_css("img")

    {
      src: image.try(:[], "src") || Logo.default_image,
      alt: image.try(:[], "alt").presence || content.title
    }
  end

  def absolute_image_url(src)
    return if src.blank?

    URI.join(request.base_url, src).to_s
  rescue URI::InvalidURIError
    nil
  end
end
