module NodeHelper

  ContentPresenter = Struct.new(:record, :title, :meta, :image, :body, :actions, :css_class) do
    def to_hash
      attrs = members.map(&:to_sym)
      Hash[*attrs.zip(values).flatten]
    end
  end

  def article_for(record)
    cp = ContentPresenter.new
    cp.record = record
    cp.css_class = 'content'
    cp.css_class << ' new-content' if current_user && record.node.read_status(current_user) == :not_read
    yield cp
    cp.meta ||= posted_by(record)
    cp.body ||= sanitize(record.body)
    render 'nodes/content', cp.to_hash
  end

  def link_to_content(content)
    link_to h(content.title), url_for_content(content)
  end

  def paginated_contents(contents)
    paginated_section(contents) do
      concat(content_tag(:div, render(contents), :id => 'contents'))
    end
  end

  def pubdate_for(content)
    (content.created_at || Time.now).iso8601
  end

  def posted_by(content, user_link=nil)
    user = content.user || current_user
    user_link  ||= link_to(h(user.name), user, :rel => 'author')
    date_time    = content.created_at || Time.now
    published_at = content_tag(:time, date_time.to_s(:posted), :datetime => pubdate_for(content))
    "Posté par #{user_link} le #{published_at}."
  end

  def read_it(content)
    link = link_to("Lire la suite", url_for_content(content))
    nb_comments = pluralize(content.node.try(:comments_count), "commentaire")
    if current_user
      visit = case content.node.read_status(current_user)
              when :not_read     then ", non visité"
              when :new_comments then ", Nouveaux !"
              else                    ", déjà visité"
              end
    end
    "&gt; #{link} (#{nb_comments}#{visit})."
  end

end
