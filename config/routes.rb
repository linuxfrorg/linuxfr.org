ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'home'

  # News
  map.resources :sections
  map.resources :news

  # Diaries & Users
  map.resources :users
  map.resources :diaries, :as => 'journaux'

  # Forums
  map.resources :forums, :has_many => [:posts]
  map.with_options :controller => 'posts' do |p|
    p.new_post   '/posts/new', :action => 'new'
    p.post_posts '/posts',     :action => 'create', :conditions => { :method => :post }
  end

  # Other contents
  map.resources :interviews, :collection => { :comments => :get }, :as => 'entretiens'
  map.resources :polls, :member => { :vote => :post }, :as => 'sondages'
  map.resources :trackers, :collection => { :comments => :get }, :as => 'suivi'
  map.resources :wiki_pages, :as => 'wiki' do |wiki|
    wiki.show_diff '/show_diff/:sha', :controller => 'wiki_pages', :action => 'show_diff'
  end

  # Nodes
  map.resources :nodes do |node|
    node.resources :comments
    map.with_options :controller => 'tags' do |t|
      t.new_tag   '/tags/new', :action => 'new'
      t.node_tags '/tags',     :action => 'create', :conditions => { :method => :post }
    end
  end
  map.with_options :controller => 'tags' do |t|
    t.tags       '/tags',            :action => 'index'
    t.tag        '/tags/:id',        :action => 'show'
    t.public_tag '/tags/:id/public', :action => 'public'
  end
  map.answer_comment '/nodes/:node_id/comments/:parent_id/answer', :controller => 'comments', :action => 'new'
  map.vote '/vote/:action/:node_id', :controller => 'votes'
  map.relevance '/relevance/:action/:comment_id', :controller => 'relevances'

  # Boards
  map.with_options :controller => 'boards' do |b|
    b.add_board '/board/add', :action => 'add', :conditions => { :method => :post }
    b.with_options :action => 'index' do |i|
      i.writing_board  '/redaction',       :id => Board.writing
      i.free_board     '/board',           :id => Board.free
      i.free_board_xml '/board/index.xml', :id => Board.free, :format => 'xml'
    end
  end

  # Accounts
  map.resource :account, :as => 'compte'
  map.with_options :controller => 'accounts' do |a|
    a.signup           '/inscription', :action => 'new'
    a.activate   '/activation/:token', :action => 'activate',        :token => nil
    a.forgot_password '/mot-de-passe', :action => 'forgot_password', :conditions => { :method => :get }
    a.send_password   '/mot-de-passe', :action => 'send_password',   :conditions => { :method => :post }
    a.reset_password  '/reset/:token', :action => 'reset_password',  :token => nil
    a.close_account '/desinscription', :action => 'delete'
  end

  # Sessions
  map.resource :account_session, :as => 'session'
  map.with_options :controller => 'account_sessions' do |a|
    a.login  '/login',  :action => 'new'
    a.logout '/logout', :action => 'destroy'
  end

  # Moderation
  map.namespace :moderation do |m|
    # TODO should we use PUT instead of POST for accept/refuse?
    m.resources :news, :member => { :accept => :post, :refuse => :post, :ppp => :post } do |news|
      news.show_diff '/show_diff/:sha', :controller => 'news', :action => 'show_diff'
    end
    m.resources :interviews, :member => { :accept => :post, :refuse => :post, :contact => :post, :publish => :post }, :as => 'entretiens'
    m.resources :polls, :member => { :accept => :post, :refuse => :post }, :as => 'sondages'
  end

  # Admin
  map.namespace :admin do |admin|
    admin.resources :sections
    admin.resources :forums
    admin.resources :categories
  end

  # Default routes (should not be used)
  # TODO remove them
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  # Static pages
  map.static ':action', :controller => 'static'
end
