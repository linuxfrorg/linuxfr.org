ActionController::Routing::Routes.draw do |map|
  # Contents
  map.resources :sections
  map.resources :news
  map.resources :diaries, :as => 'journaux'
  map.resources :forums, :has_many => [:posts]
  map.resources :polls, :as => 'sondages'
  map.resources :trackers, :as => 'suivi'
  map.resources :wiki_pages, :as => 'wiki' do |wiki|
    wiki.show_diff '/show_diff/:sha', :controller => 'wiki_pages', :action => 'show_diff'
  end

  # Nodes
  map.root :controller => 'home'
  map.resources :nodes do |node|
    node.resources :comments
    node.new_tag '/tags/new', :controller => 'tags', :action => 'new'
    node.connect '/tags', :controller => 'tags', :action => 'create', :conditions => { :method => :post }
  end
  map.tags '/tags', :controller => 'tags', :action => 'index'
  map.tag '/tags/:id', :controller => 'tags', :action => 'show'
  map.public_tag '/tags/:id/public', :controller => 'tags', :action => 'public'
  map.answer_comment '/nodes/:node_id/comments/:parent_id/answer', :controller => 'comments', :action => 'new'
  map.vote '/vote/:action/:node_id', :controller => 'votes'
  map.relevance '/relevance/:action/:comment_id', :controller => 'relevances'

  # Boards
  map.add_board '/board/add', :controller => 'boards', :action => 'add', :conditions => { :method => :post }
  map.writing_board '/redaction', :controller => 'boards', :action => 'index', :id => Board.writing
  map.free_board '/board', :controller => 'boards', :action => 'index', :id => Board.free
  map.free_board_xml '/board/index.xml', :controller => 'boards', :action => 'index', :id => Board.free, :format => 'xml'

  # User account and session
  map.resources :users
  map.resource :session
  map.signup '/inscription', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.activate '/activation/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil

  # Moderation
  map.namespace :moderation do |moderation|
    moderation.resources :news, :member => { :accept => :post, :refuse => :post } do |news|
      news.show_diff '/show_diff/:sha', :controller => 'news', :action => 'show_diff'
    end
  end

  # Admin
  map.namespace :admin do |admin|
    admin.resources :sections
    admin.resources :forums
    admin.resources :categories
  end

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.static ':action', :controller => 'static'
end
