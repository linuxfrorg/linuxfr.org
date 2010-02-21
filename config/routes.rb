LinuxfrOrg::Application.routes.draw do
  # TODO Rails 3
  # http://guides.rails.info/routing.html
  # http://yehudakatz.com/2009/12/26/the-rails-3-router-rack-it-up/
  #
  # TODO :only & :except

  root :to => 'home#index'

  # News
  resources :sections
  match '/news(.:format)', :to => 'news#index', :as => 'news_index'
  resources :news, :except => [:index]
  match '/redirect/:id' => 'links#show'

  # Diaries & Users
  resources :users do
    resources :diaries, :as => 'journaux'
  end
  match '/journaux(.:format)' => 'diaries#index', :as => :diaries, :via => 'get'
  match '/journaux/nouveau' => 'diaries#new', :as => :new_diary, :via => 'get'
  match '/journaux' => 'diaries#create', :as => :post_diary, :via => 'post'

  # Forums
  resources :forums
  match '/posts/nouveau' => 'posts#new', :as => :new_post, :via => 'get'
  match '/posts' => 'posts#create', :as => :post_posts, :via => 'post'

  # Other contents
  resources :polls, :as => 'sondages' do
    post :vote, :on => :member
  end
  resources :trackers, :as => 'suivi' do
    get :comments, :on => :collection
  end
  match '/wiki/changes' => 'wiki_pages#changes', :as => :wiki_changes
  resources :wiki_pages, :as => 'wiki' do
    member do
      match '/revisions/:revision' => 'wiki_pages#revision', :as => :revision
    end
  end

  # Nodes
  match '/tableau-de-bord' => 'dashboard#index', :as => :dashboard
  resources :nodes do
    resources :comments
    member do
      match '/tags/new' => 'tags#new', :as => :new_tag, :via => 'get'
      match '/tags' => 'tags#create', :as => :tags, :via => 'post'
    end
  end
  match '/tags' => 'tags#index', :as => :tags, :via => 'get'
  match '/tags/autocomplete' => 'tags#autocomplete_for_tag_name', :as => :complete_tags, :via => 'get'
  match '/tags/:id' => 'tags#show', :as => :tag, :via => 'get'
  match '/tags/:id/public' => 'tags#public', :as => :public_tag, :via => 'get'
  match '/nodes/:node_id/comments/:parent_id/answer' => 'comments#new', :as => :answer_comment
  match '/vote/:action/:node_id' => 'votes#index', :as => :vote
  match '/relevance/:action/:comment_id' => 'relevances#index', :as => :relevance

  # Boards
  match '/board/add' => 'boards#add', :as => :add_board, :via => 'post'
  match '/board' => 'boards#show', :as => :free_board
  match '/board/index.xml' => 'boards#show', :as => :free_board_xml, :format => 'xml'

  # Accounts
  resource :account, :as => 'compte' do
    resource :stylesheet
  end
  match '/inscription' => 'accounts#new', :as => :signup
  match '/activation/:token' => 'accounts#activate', :as => :activate, :token => ''
  match '/mot-de-passe' => 'accounts#forgot_password', :as => :forgot_password, :via => 'get'
  match '/mot-de-passe' => 'accounts#send_password', :as => :send_password, :via => 'post'
  match '/reset/:token' => 'accounts#reset_password', :as => :reset_password, :token => ''
  match '/desinscription' => 'accounts#delete', :as => :close_account

  # Sessions
  resource :account_session, :as => 'session'
  match '/login' => 'account_sessions#new', :as => :login
  match '/logout' => 'account_sessions#destroy', :as => :logout

  # Search
  match '/recherche' => 'search#index', :as => :search
  match '/recherche/:type' => 'search#type', :as => :search_by_type
  match '/recherche/:type/:facet' => 'search#facet', :as => :search_by_facet

  # Redaction
  match '/redaction' => 'redaction#index'
  namespace :redaction do
    resources :news do
      post :submit, :on => :member
    end
    resources :paragraphs
    resources :links
    match '/news/:news_id/links/nouveau' => 'links#new', :as => :news_new_link
  end

  # Moderation
  match '/moderation' => 'moderation#index'
  namespace :moderation do
    resources :news do
      member do
        match '/show_diff/:sha' => 'news#show_diff', :as => :show_diff
      end
    end
    resources :polls, :as => 'sondages' do
      member do
        post :refuse
        post :accept
      end
    end
  end

  # Admin
  match '/admin' => 'admin#index'
  namespace :admin do
    resources :accounts, :as => 'comptes'
    resources :responses, :as => 'reponses'
    resources :sections
    resources :forums
    resources :categories
    resources :banners, :as => 'bannieres'
    resource :logo
    resources :friend_sites, :as => 'sites_amis' do
      member do
        post :lower
        post :higher
      end
    end
    resources :pages
  end

  # Static pages
  match '/proposer_un_contenu' => 'static#proposer_un_contenu', :as => :submit_content
  match '/proposer_un_contenu_quand_on_est_anonyme' => 'static#proposer_un_contenu_quand_on_est_anonyme', :as => :submit_anonymous
  match '/changelog' => 'static#changelog', :as => :changelog
  match ':id' => 'static#show', :as => :static
end
