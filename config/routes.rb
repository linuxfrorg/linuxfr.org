# encoding: utf-8
#
Rails.application.routes.draw do
  root to: "home#index"

  # News
  resources :sections, only: [:index, :show]
  get "/news" => "news#index", as: "news_index"
  resources :news, only: [:show, :new, :create]
  get "/redirect/:id" => "links#show"
  get "/:year/:month/:day" => "news#calendar", year: /(19|20)\d{2}/, month: /[01]?\d/, day: /[0-3]?\d/

  # Diaries & Users
  resources :users, only: [:show] do
    resources :journaux, controller: "diaries", as: "diaries", except: [:index, :new, :create] do
      member do
        post :convert
        post :move
      end
    end
    resources :liens, controller: "bookmarks", as: "bookmarks", except: [:index, :new, :create]
    member do
      get :news
      get :journaux
      get :liens
      get :posts
      get :suivi
      get :comments
      get :wiki
    end
  end
  resources :journaux, controller: "diaries", as: "diaries", only: [:index, :new, :create]
  resources :liens, controller: "bookmarks", as: "bookmarks", only: [:index, :new, :create]

  # Forums
  resources :forums, only: [:index, :show] do
    resources :posts, except: [:new, :create]
  end
  resources :posts, only: [:new, :create]

  # Other contents
  resources :sondages, controller: "polls", as: "polls", except: [:edit, :update, :destroy] do
    member { post :vote }
  end
  resources :suivi, controller: "trackers", as: "trackers" do
    collection { get :comments }
  end
  resources :wiki, controller: "wiki_pages", as: "wiki_pages" do
    collection do
      get "pages" => :pages
      get "modifications" => :changes
    end
    member do
      get "/revisions/:revision" => :revision, as: :revision
    end
  end

  # Nodes
  get "/tableau-de-bord" => "dashboard#index", as: :dashboard
  get "/tableau-de-bord/reponses" => "dashboard#answers"
  get "/comments/:id(,:d)(.html)" => "comments#templeet"
  resources :nodes, only: [] do
    resources :comments do
      member do
        get :answer
        post "/relevance/for",     controller: "relevances", action: :for
        post "/relevance/against", controller: "relevances", action: :against
      end
    end
    resources :tags, only: [:new, :create, :update, :destroy]
    member do
      post "/vote/for",     controller: "votes", action: :for
      post "/vote/against", controller: "votes", action: :against
    end
  end
  resources :readings, only: [:index, :destroy]
  delete "readings" => "readings#destroy_all"
  resources :tags, only: [:index, :show] do
    collection do
      get :autocomplete
    end
    member do
      get :public
      post :hide
    end
  end

  # Boards
  controller :boards do
    get  "/board/index" => :show
    get  "/board" => :show
    post "/board" => :create
  end

  # Accounts
  devise_for :account, path: "compte", controllers: {
    registrations: "registrations"
  }, path_names: {
    sign_in: "connexion",
    sign_out: "deconnexion",
    sign_up: "inscription",
    unlock: "debloquage"
  }
  resource :stylesheet, only: [:create, :edit, :update, :destroy]

  # API
  scope :api do
    use_doorkeeper do
      skip_controllers :applications, :authorized_applications
    end
  end
  namespace :api do
    resources :applications
    resources :authorized_applications, only: [:destroy]
    namespace :v1 do
      get  "/me"    => "accounts#me"
      post "/board" => "board#create"
      post "/journaux" => "diary#create"
      post "/news" => "news#create"
    end
  end

  # Redaction
  get "/redaction" => "redaction#index"
  namespace :redaction do
    resources :news, except: [:new, :destroy] do
      collection { get :moderation }
      member do
        get "/revisions/:revision" => :revision, as: :revision
        post :submit
        post :followup
        post :erase
        post :reassign
        post :urgent
        post :cancel_urgent
        get :reorganize
        put :reorganized
        get :edit_figure
        post :update_figure
      end
      resources :links, only: [:new]
      resources :paragraphs, only: [:create]
    end
    resources :links, only: [:create, :edit, :update] do
      member { post :unlock }
    end
    resources :paragraphs, only: [:show, :edit, :update] do
      member { post :unlock }
    end
  end

  # Moderation
  get "/moderation" => "moderation#index"
  namespace :moderation do
    resources :news, except: [:new, :create, :destroy] do
      member do
        post :accept
        post :refuse
        post :rewrite
        post :reset
        post :ppp
        get :vote
      end
    end
    resources :sondages, controller: "polls", as: "polls", except: [:new, :create, :destroy] do
      member do
        post :refuse
        post :accept
        post :ppp
      end
    end
    resources :plonk, only: [:create]
    resources :block, only: [:create]
    resources :images, only: [:index, :destroy]
    resources :tags, only: [:index]
  end

  # Admin
  get "/admin"       => "admin#index"
  get "/admin/debug" => "admin#debug"
  namespace :admin do
    resources :comptes, controller: "accounts", as: "accounts", only: [:index, :update, :destroy] do
      resource :moderator, only: [:create, :destroy]
      resource :editor, only: [:create, :destroy]
      resource :admin, only: [:create, :destroy]
      member do
        post :password
        post :karma
      end
    end
    resources :reponses, controller: "responses", as: "responses", except: [:show]
    resources :sections, except: [:show]
    resources :forums, except: [:show] do
      member do
        post :archive
        post :reopen
        post :lower
        post :higher
      end
    end
    resources :categories, except: [:show]
    resources :bannieres, controller: "banners", as: "banners", except: [:show]
    resource :logo, only: [:show, :create]
    resource :stylesheet, only: [:show, :create]
    resources :sites_amis, controller: "friend_sites", as: "friend_sites", except: [:show] do
      member do
        post :lower
        post :higher
      end
    end
    resources :pages, except: [:show]
    resources :applications, except: [:new, :create]
  end

  # Search
  get "/recherche(/:type(/:facet))" => "search#index", as: :search

  # Statistics
  %i(tracker prizes users top moderation redaction contents comments tags applications).each do |action|
    get "/statistiques/#{action}", controller: :statistics, action: action
  end

  # Static pages
  controller :static do
    get "/proposer-un-contenu" => :submit_content, as: :submit_content
    get "/changelog" => :changelog, as: :changelog
    get "/:id" => :show, as: :static, constraints: { id: /[a-z_\-]+/ }
  end
end
