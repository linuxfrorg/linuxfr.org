module ApplicationHelper

  def title(title, tag=nil)
    title = h(title)
    @title << title
    content_tag(tag, title) if tag
  end

  def h1(str)
    title(str, :h1)
  end

  def feed(title, link=nil)
    link ||= { :format => :atom }
    @feeds[link] = title
  end

  def meta_for(content)
    @author      = content.user.name if content.respond_to?(:user) && content.user
    @keywords   += content.node.popular_tags.map &:name
    @description = content.title
  end

  def admin_only(&blk)
    blk.call if current_user && current_user.admin?
  end

  def amr_only(&blk)
    blk.call if current_user && current_user.amr?
  end

  def writer_only(&blk)
    blk.call if current_user && (current_user.writer? || current_user.amr?)
  end

  def spellify(str)
    speller = Aspell.new('fr_FR', nil, nil, 'utf-8')
    speller.set_option('mode', 'html')
    ary = [HTMLEntities.decode_entities(str)]
    res = speller.correct_lines(ary) { |word| "<span class=\"misspelled\">#{word}</span>" }
    res.first
  end

end
