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

  def admin_only(&blk)
    blk.call if current_user && current_user.admin?
  end

  def amr_only(&blk)
    blk.call if current_user && current_user.amr?
  end

  def article_for(record, &blk)
    content_tag_for(:article, record, :class => 'content', &blk)
  end

end
