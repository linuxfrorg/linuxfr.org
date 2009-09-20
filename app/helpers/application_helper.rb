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

  def keywords_from_tags(tags)
    tags = tags.map {|t| t.name }
    @keywords += tags
  end

  def body_attr
    classes = %w(js-off)
    classes << 'logged' if current_user
    classes << current_user.role if current_user
    classes << Rails.env if Rails.env != 'production'
    { :class => classes.join(' ') }
  end

  def check_js
    javascript_tag "document.body.className = document.body.className.replace('js-off', 'js-on');"
  end

  def logo
    img = Dictionary['logo']
    content_tag(:h1, :style => "background-image: url('/images/logos/#{img}');") do
      link_to "LinuxFr.org", '/'
    end
  end

  def admin_only(&blk)
    blk.call if current_user && current_user.admin?
  end

  def amr_only(&blk)
    blk.call if current_user && current_user.amr?
  end

  def spellify(str)
    speller = Aspell.new('fr_FR', nil, nil, 'utf-8')
    speller.set_option('mode', 'html')
    ary = [HTMLEntities.decode_entities(str)]
    res = speller.correct_lines(ary) { |word| "<span class=\"misspelled\">#{word}</span>" }
    res.first
  end

end
