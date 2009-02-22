module ApplicationHelper

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
