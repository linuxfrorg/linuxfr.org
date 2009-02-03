ActionController::Routing::Routes.draw do |map|
  # Contents
  map.resources :sections
  map.resources :news
  map.resources :diaries
  map.resources :forums, :has_many => [:posts]

  # Nodes
  map.root :controller => 'home'
  map.resources :nodes, :has_many => [:comments]
  map.answer_comment '/nodes/:node_id/comments/:parent_id/answer', :controller => 'comments', :action => 'new'
  map.vote '/vote/:action/:node_id', :controller => 'votes'

  # User account and session
  map.resources :users
  map.resource :session
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil

  # Moderation
  map.namespace :moderation do |moderation|
    moderation.resources :news, :member => { :accept => :post, :refuse => :post } do |news|
      news.show_diff '/show_diff/:sha', :controller => 'news', :action => 'show_diff'
    end
  end

  # Admin
  map.namespace :admin do |admin|
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
end
