# http://guides.rails.info/routing.html
# http://yehudakatz.com/2009/12/26/the-rails-3-router-rack-it-up/
#
LinuxfrOrg::Application.routes.draw do
  root :to => "home#index"

  # News
  resources :sections, :only => [:index, :show]
  get "/news(.:format)" => "news#index", :as => "news_index"
  resources :news, :only => [:show, :new, :create]
  get "/redirect/:id" => "links#show"
  get "/:year/:month/:day" => "news#calendar", :year => /(19|20)\d{2}/, :month => /[01]?\d/, :day => /[0-3]?\d/

  # Diaries & Users
  resources :users, :only => [:show] do
    resources :journaux, :controller => "diaries", :as => "diaries", :except => [:index, :new, :create]
    get :news, :on => :member
    get :posts, :on => :member
    get :suivi, :on => :member
    get :comments, :on => :member
  end
  resources :journaux, :controller => "diaries", :as => "diaries", :only => [:index, :new, :create]

  # Forums
  resources :forums, :only => [:index, :show] do
    resources :posts, :except => [:new, :create]
  end
  resources :posts, :only => [:new, :create]

  # Other contents
  resources :sondages, :controller => "polls", :as => "polls", :except => [:edit, :update, :destroy] do
    post :vote, :on => :member
  end
  resources :suivi, :controller => "trackers", :as => "trackers" do
    get :comments, :on => :collection
  end
  resources :wiki, :controller => "wiki_pages", :as => "wiki_pages" do
    get "pages" => :pages, :on => :collection
    get "modifications" => :changes, :on => :collection
    get "/revisions/:revision" => :revision, :as => :revision, :on => :member
  end

  # Nodes
  get "/tableau-de-bord" => "dashboard#index", :as => :dashboard
  get "/comments/:id(,:d)(.html)" => "comments#templeet"
  resources :nodes, :only => [] do
    resources :comments do
      get :answer, :on => :member
      post "/relevance/:action" => "relevances#index", :as => :relevance, :on => :member
    end
    resources :tags, :only => [:new, :create]
    post "/vote/:action" => "votes#index", :as => :vote, :on => :member
  end
  resources :tags, :only => [:index, :show] do
    get :autocomplete, :on => :collection
    get :public, :on => :member
  end

  # Boards
  controller :boards do
    get  "/board/index.xml" => :show, :format => :xml
    get  "/board" => :show
    post "/board" => :create, :as => :board
  end

  # Accounts
  devise_for :account, :path => "compte", :controllers => {
    :sessions => "sessions"
  }, :path_names => {
    :sign_in  => "connexion",
    :sign_out => "deconnexion",
    :sign_up  => "inscription",
    :unlock   => "debloquage"
  }
  resource :stylesheet, :only => [:edit, :create, :destroy]

  # Search
  # TODO Thinking Sphinx compatible with Rails3
  #controller :search do
  #  get "/recherche" => :index, :as => :search
  #  get "/recherche/:type" => :type, :as => :search_by_type
  #  get "/recherche/:type/:facet" => :facet, :as => :search_by_facet
  #end
  get "/recherche" => "search#google", :as => :search

  # Redaction
  get "/redaction" => "redaction#index"
  namespace :redaction do
    resources :news, :except => [:new, :destroy] do
      post :submit, :on => :member
      resources :links, :only => [:new]
      resources :paragraphs, :only => [:create]
    end
    resources :links, :only => [:create, :edit, :update]
    resources :paragraphs, :only => [:show, :edit, :update]
  end

  # Moderation
  get "/moderation" => "moderation#index"
  namespace :moderation do
    resources :news, :except => [:new, :create, :destroy] do
      post :accept, :on => :member
      post :refuse, :on => :member
      post :ppp, :on => :member
      post :clear_locks, :on => :member
    end
    resources :sondages, :controller => "polls", :as => "polls", :except => [:new, :create, :destroy] do
      post :refuse, :on => :member
      post :accept, :on => :member
    end
  end

  # Admin
  get "/admin"       => "admin#index"
  get "/admin/debug" => "admin#debug"
  namespace :admin do
    resources :comptes, :controller => "accounts", :as => "accounts", :only => [:index, :update, :destroy]
    resources :reponses, :controller => "responses", :as => "responses", :except => [:show]
    resources :sections, :except => [:show]
    resources :forums, :except => [:show]
    resources :categories, :except => [:show]
    resources :bannieres, :controller => "banners", :as => "banners", :except => [:show]
    resource :logo, :only => [:show, :create]
    resource :stylesheet, :only => [:show, :create]
    resources :sites_amis, :controller => "friend_sites", :as => "friend_sites", :except => [:show] do
      post :lower,  :on => :member
      post :higher, :on => :member
    end
    resources :pages, :except => [:show]
  end

  # Static pages
  controller :static do
    get "/proposer-un-contenu" => :submit_content, :as => :submit_content
    get "/changelog" => :changelog, :as => :changelog
    get "/:id" => :show, :as => :static, :constraints => { :id => /[a-z_\-]+/ }
  end
end
