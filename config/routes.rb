ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'home'

  # News
  map.resources :sections
  map.resources :news
  map.connect '/redirect/:id', :controller => 'links', :action => 'show'

  # Diaries & Users
  map.resources :users do |u|
    u.resources :diaries, :as => 'journaux'
  end
  map.with_options :controller => 'diaries' do |d|
    d.diaries    '/journaux',         :action => 'index',  :conditions => { :method => :get }
    d.diaries    '/journaux.:format', :action => 'index',  :conditions => { :method => :get }
    d.new_diary  '/journaux/nouveau', :action => 'new',    :conditions => { :method => :get }
    d.post_diary '/journaux',         :action => 'create', :conditions => { :method => :post }
  end

  # Forums
  map.resources :forums, :has_many => [:posts]
  map.with_options :controller => 'posts' do |p|
    p.new_post   '/posts/nouveau', :action => 'new',    :conditions => { :method => :get }
    p.post_posts '/posts',         :action => 'create', :conditions => { :method => :post }
  end

  # Other contents
  map.resources :interviews, :collection => { :comments => :get }, :as => 'entretiens'
  map.resources :polls, :member => { :vote => :post }, :as => 'sondages'
  map.resources :trackers, :collection => { :comments => :get }, :as => 'suivi'
  map.resources :wiki_pages, :as => 'wiki' do |wiki|
    wiki.show_diff '/show_diff/:sha', :controller => 'wiki_pages', :action => 'show_diff'
  end

  # Nodes
  map.dashboard '/tableau-de-bord', :controller => 'dashboard', :action => 'index'
  map.resources :nodes do |node|
    node.resources :comments
    map.with_options :controller => 'tags' do |t|
      t.node_new_tag '/nodes/:node_id/tags/new', :action => 'new',    :conditions => { :method => :get }
      t.node_tags    '/nodes/:node_id/tags',     :action => 'create', :conditions => { :method => :post }
    end
  end
  map.with_options :controller => 'tags' do |t|
    t.tags          '/tags',              :action => 'index',                     :conditions => { :method => :get }
    t.complete_tags '/tags/autocomplete', :action => 'autocomplete_for_tag_name', :conditions => { :method => :get }
    t.tag           '/tags/:id',          :action => 'show',                      :conditions => { :method => :get }
    t.public_tag    '/tags/:id/public',   :action => 'public',                    :conditions => { :method => :get }
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
  map.resource :account, :has_one => :stylesheet, :as => 'compte'
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

  # Search
  map.search          '/recherche',              :controller => 'search'
  map.search_by_type  '/recherche/:type',        :controller => 'search', :action => 'type'
  map.search_by_facet '/recherche/:type/:facet', :controller => 'search', :action => 'facet'

  # Moderation
  map.connect '/moderation', :controller => 'moderation'
  map.namespace :moderation do |m|
    m.resources :news, :member => { :accept => :post, :refuse => :post, :ppp => :post } do |news|
      news.show_diff '/show_diff/:sha', :controller => 'news', :action => 'show_diff'
    end
    m.resources :interviews, :member => { :accept => :post, :refuse => :post, :contact => :post, :publish => :post }, :as => 'entretiens'
    m.resources :polls, :member => { :accept => :post, :refuse => :post }, :as => 'sondages'
  end

  # Admin
  map.connect '/admin', :controller => 'admin'
  map.namespace :admin do |admin|
    admin.resources :accounts,  :as => 'comptes'
    admin.resources :responses, :as => 'reponses'
    admin.resources :sections
    admin.resources :forums
    admin.resources :categories
    admin.resources :banners, :as => 'bannieres'
    admin.resource  :logo
    admin.resources :friend_sites, :member => { :lower => :post, :higher => :post }, :as => 'sites_amis'
    admin.resources :pages
  end

  # Static pages
  map.submit_content   '/proposer_un_contenu', :controller => 'static', :action => 'proposer_un_contenu'
  map.submit_anonymous '/proposer_un_contenu_quand_on_est_anonyme', :controller => 'static', :action => 'proposer_un_contenu_quand_on_est_anonyme'
  map.changelog        '/changelog', :controller => 'static', :action => 'changelog'
  map.static ':id', :controller => 'static', :action => 'show'
end
