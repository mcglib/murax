Rails.application.routes.draw do
  concern :oai_provider, BlacklightOaiProvider::Routes.new

  concern :bulk_operatable do
    collection do
      get 'bulk_operate/:operation', :action => :bulk_operate
      post :bulk_operate
    end

  end

  mount BrowseEverything::Engine => '/browse'

  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?
    concern :searchable, Blacklight::Routes::Searchable.new


  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :oai_provider
    concerns :searchable

  end

  devise_for :users

  mount Hydra::RoleManagement::Engine => '/'
  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'

  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  namespace :admin do
    resources :admin_sets do
      member do
        get :files
      end
      resource :permission_template
    end
  
    # McGill library import logs from digitool
    resources :batches, path: '/digitool-imports/batches/' do
      collection do
        get :import
	      post :ingest
      end
      resources :import_logs, only: [:show, :index, :edit, :destroy]  do
        collection do
          delete 'clear'
        end
      end
    end

    resources :users, only: [:index]
    resources :permission_template_accesses, only: :destroy
    resource 'stats', only: [:show]
    resources :features, only: [:index] do
      resources :strategies, only: [:update, :destroy]
    end
    resources :workflows
    resources :workflow_roles
    resource :appearance
    resources :collection_types, except: :show
    resources :collection_type_participants, only: [:create, :destroy]
  end

  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'


  

  authenticate :user, ->(u) { u.admin? } do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # Custom errors
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all
  get '/404', to: "errors#not_found"
  get '/422', to: "errors#unacceptable"
  get '/500', to: "errors#internal_server_error"

end
