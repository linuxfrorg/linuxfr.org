class AnonymousConstraint
  def self.matches?(request)
    !request.cookies.has_key? "linuxfr.org_session"
  end
end


# http://guides.rails.info/routing.html
# http://yehudakatz.com/2009/12/26/the-rails-3-router-rack-it-up/
#
LinuxfrOrg::Application.routes.draw do
  # These routes are here only for cacheability reasons
  constraints(AnonymousConstraint) do
    get "/"         => "home#anonymous"
    get "/news/:id" => "news#anonymous"
  end

  root :to => "home#index"

  # News
  resources :sections, :only => [:index, :show]
  get "/news(.:format)" => "news#index", :as => "news_index"
  resources :news, :only => [:show, :new, :create]
  get "/redirect/:id" => "links#show"

  # Diaries & Users
  resources :users, :only => [:show] do
    resources :journaux, :controller => "diaries", :as => "diaries", :except => [:index, :new, :create]
  end
  resources :diaries, :controller => "diaries", :as => "diaries", :only => [:index, :new, :create]

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
    get :changes, :on => :collection
    get "/revisions/:revision" => "wiki_pages#revision", :as => :revision, :on => :member
  end

  # Nodes
  get "/tableau-de-bord" => "dashboard#index", :as => :dashboard
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
  post "/board/add" => "boards#add", :as => :add_board
  get  "/board" => "boards#show", :as => :free_board
  get  "/board/index.xml" => "boards#show", :as => :free_board_xml, :format => "xml"

  # Accounts
  devise_for :account, :as => "compte", :controllers => {
    :sessions => "sessions"
  }, :path_names => {
    :sign_in  => "connexion",
    :sign_out => "deconnexion",
    :sign_up  => "inscription",
    :unlock   => "debloquage"
  }
  resource :stylesheet, :only => [:edit, :create, :destroy]

  # Search
  get "/recherche" => "search#index", :as => :search
  get "/recherche/:type" => "search#type", :as => :search_by_type
  get "/recherche/:type/:facet" => "search#facet", :as => :search_by_facet

  # Redaction
  namespace :redaction do
    root :to => "redaction#index"
    resources :news, :except => [:new, :destroy] do
      post :submit, :on => :member
      resources :links, :only => [:new, :create]
    end
    resources :links, :only => [:edit, :update]
    resources :paragraphs, :only => [:show, :edit, :update]
  end

  # Moderation
  namespace :moderation do
    root :to => "moderation#index"
    resources :news, :except => [:new, :create, :destroy] do
      post :accept, :on => :member
      post :refuse, :on => :member
      post :ppp, :on => :member
      post :clear_locks, :on => :member
      get "/show_diff/:sha" => "news#show_diff", :as => :show_diff, :on => :member
    end
    resources :sondages, :controller => "polls", :as => "polls", :except => [:new, :create, :destroy] do
      post :refuse, :on => :member
      post :accept, :on => :member
    end
  end

  # Admin
  namespace :admin do
    root :to => "admin#index"
    resources :comptes, :controller => "accounts", :as => "accounts", :only => [:index, :update, :destroy]
    resources :reponses, :controller => "responses", :as => "responses", :except => [:show]
    resources :sections, :except => [:show]
    resources :forums, :except => [:show]
    resources :categories, :except => [:show]
    resources :bannieres, :controller => "banners", :as => "banners", :except => [:show]
    resource :logo, :only => [:show, :create]
    resources :sites_amis, :controller => "friend_sites", :as => "friend_sites", :except => [:show] do
      post :lower,  :on => :member
      post :higher, :on => :member
    end
    resources :pages, :except => [:show]
  end

  # Static pages
  match "/proposer-un-contenu" => "static#submit_content", :as => :submit_content
  match "/proposer-un-contenu-en-anonyme" => "static#submit_anonymous", :as => :submit_anonymous
  match "/changelog" => "static#changelog", :as => :changelog
  # FIXME
  match "/:id" => "static#show", :as => :static#, :id => /^[a-z_]+$/
end
