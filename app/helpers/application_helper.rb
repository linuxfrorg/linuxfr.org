module ApplicationHelper

  def title(title, tag=nil)
    @title << title
    content_tag(tag, title) if tag
  end

  def h2(str)
    title(str, :h2)
  end

  def feed(title, link)
    @feeds[link] = title
  end

  def keywords_from_tags(tags)
    tags = tags.map(&:name)
    @keywords += tags
  end

  def body_attr
    classes = %w(js-off)
    classes << current_user.role if current_user && current_user.amr?
    classes << Rails.env if Rails.env != 'production'
    { :class => classes.join(' ') }
  end

  def check_js
    javascript_tag "document.body.className = document.body.className.replace('js-off', 'js-on');"
  end

  def admin_only(&blk)
    blk.call if current_user && current_user.admin?
  end

  def amr_only(&blk)
    blk.call if current_user && current_user.amr?
  end

  def article_for(record, &blk)
    content_tag_for(:article, record, :class => 'content', &blk)
  end

  def posted_by(content)
    user = content.user || current_user
    user_link = link_to(user.public_name, user)
    date_time = (content.created_at || DateTime.now).to_s(:posted)
    "Posté par #{user_link} le #{date_time}."
  end

  def read_it(content)
    link = link_to("Lire la suite", url_for_content(content))
    nb_comments = pluralize(content.node.try(:comments).try(:count), "commentaire") # FIXME comments_count
    "> #{link} (#{nb_comments})."
  end

end
