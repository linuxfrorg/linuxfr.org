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
    tags = tags.map {|t| h(t.name) }
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

  def article_for(record, &blk)
    content_tag_for(:article, record, :class => 'content', &blk)
  end

  def link_to_content(content)
    link_to h(content.title), url_for_content(content)
  end

  def posted_by(content, user_link=nil)
    user = content.user || current_user
    user_link ||= link_to(h(user.name), user)
    date_time   = (content.created_at || DateTime.now).to_s(:posted)
    "Posté par #{user_link} le #{date_time}."
  end

  def read_it(content)
    link = link_to("Lire la suite", url_for_content(content))
    nb_comments = pluralize(content.node.try(:comments).try(:count), "commentaire") # FIXME comments_count
    if current_user
      visit = case content.node.read_status(current_user)
              when :not_read     then ", non visité"
              when :new_comments then ", Nouveaux !"
              else                    ", déjà visité"
              end
    end
    "&gt; #{link} (#{nb_comments}#{visit})."
  end

  def spellify(str)
    speller = Aspell.new('fr_FR', nil, nil, 'utf-8')
    speller.set_option('mode', 'html')
    ary = [HTMLEntities.decode_entities(str)]
    res = speller.correct_lines(ary) { |word| "<span class=\"misspelled\">#{word}</span>" }
    res.first
  end

end
