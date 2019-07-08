# rubocop:disable LineLength

Rails.application.routes.draw do
  get 'notice_dismissal/dismiss'
  get 'customization/content_types'
  post 'customization/toggle_content_type'

  # User-centric stuff
  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :users do
    # get :characters, on: :member <...etc...>
    Rails.application.config.content_types[:all].each do |content_type|
      get content_type.name.downcase.pluralize.to_sym, on: :member
      # todo page tags here
    end
  end
  get '/@:username', to: 'users#show', as: :profile_by_username

  resources :documents

  scope '/my' do
    get '/content',         to: 'main#dashboard', as: :dashboard
    get '/content/recent',  to: 'main#recent_content', as: :recent_content
    get '/content/deleted', to: 'content#deleted', as: :recently_deleted_content
    get '/prompts',         to: 'main#prompts', as: :prompts

    get '/scratchpad',      to: 'main#notes', as: :notes

    # Legacy routes: left intact so /my/documents/X URLs continue to work for everyone's bookmarks
    resources :documents

    # Billing
    scope '/billing' do
      #get '/',             to: 'subscriptions#show', as: :billing
      get '/subscription',       to: 'subscriptions#new', as: :subscription

      get '/to/:stripe_plan_id', to: 'subscriptions#change', as: :change_subscription

      get '/information',        to: 'subscriptions#information',        as: :payment_info
      post '/information',       to: 'subscriptions#information_change', as: :process_payment_info

      # This should probably be a DELETE
      get '/payment_method/delete', to: 'subscriptions#delete_payment_method', as: :delete_payment_method

      # Promotional codes
      post '/redeem', to: 'subscriptions#redeem_code'
    end
  end
  delete 'delete_my_account', to: 'users#delete_my_account'
  delete 'contributor/:id/remove', to: 'contributors#destroy', as: :remove_contributor
  get '/unsubscribe/emails/:code', to: 'emails#one_click_unsubscribe'

  # Main pages
  root to: 'main#index'

  # Info pages
  scope '/about' do
    #get '/notebook', to: 'main#about_notebook', as: :about_notebook
    get '/privacy', to: 'main#privacyinfo', as: :privacy_policy
  end

  # Landing pages
  scope '/for' do
    get '/writers', to: 'main#for_writers', as: :writers_landing
    get '/roleplayers', to: 'main#for_roleplayers', as: :roleplayers_landing
    get '/designers', to: 'main#for_designers', as: :designers_landing
  end

  # Lab apps
  scope '/app' do
    # Navigator
    get 'navigator', to: 'navigator#index'

    # Babel
    get 'babel',     to: 'lab#babel'
    post 'babel',    to: 'lab#babel'

    # Pinboard
    get 'pinboard',  to: 'lab#pinboard'
  end

  # Sessions
  get '/login',  to: 'sessions#new', as: :login
  post '/login', to: 'sessions#create', as: :login_process
  get '/logout', to: 'sessions#destroy', as: :logout

  # Planning
  scope '/plan' do
    # Core content types
    resources :universes do
      # get :characters, on: :member <...etc...>
      Rails.application.config.content_types[:all_non_universe].each do |content_type|
        get content_type.name.downcase.pluralize.to_sym, on: :member
      end
      get :changelog, on: :member
      get '/tagged/:slug', action: :index, on: :collection, as: :page_tag
    end
    Rails.application.config.content_types[:all_non_universe].each do |content_type|
      # resources :characters do
      resources content_type.name.downcase.pluralize.to_sym do
        get :changelog, on: :member
        get '/tagged/:slug', action: :index, on: :collection, as: :page_tag
      end
    end

    # Content attributes
    put '/content/sort', to: 'content#api_sort'
    resources :attribute_categories, only: [:create, :update, :destroy]
    resources :attribute_fields,     only: [:create, :update, :destroy]

    # Image handling
    delete '/delete/image/:id', to: 'image_upload#delete', as: :image_deletion

    # Attributes
    get ':content_type/attributes', to: 'content#attributes', as: :attribute_customization

    # Coming Soon TM
    get '/plots',     to: 'main#comingsoon'
  end
  get 'search/', to: 'search#results'

  authenticate :user, lambda { |u| u.site_administrator? } do
    scope 'admin' do
      get '/stats', to: 'admin#dashboard', as: :admin_dashboard
      get '/content_type/:type', to: 'admin#content_type', as: :admin_content_type
      get '/attributes', to: 'admin#attributes', as: :admin_attributes
      get '/masquerade/:user_id', to: 'admin#masquerade', as: :masquerade
      get '/unsubscribe', to: 'admin#unsubscribe', as: :mass_unsubscribe
      get '/images', to: 'admin#images', as: :image_audit
      get '/promos', to: 'admin#promos', as: :admin_promos
      post '/perform_unsubscribe', to: 'admin#perform_unsubscribe', as: :perform_unsubscribe
    end
    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  end

  scope 'export' do
    get '/', to: 'export#index', as: :notebook_export

    get '/outline', to: 'export#outline', as: :notebook_outline
    get '/notebook.json', to: 'export#notebook_json', as: :notebook_json
    get '/notebook.xml', to: 'export#notebook_xml', as: :notebook_xml
    get '/:model.csv', to: 'export#csv', as: :notebook_csv
  end

  scope '/scene/:scene_id' do
    get 'editor', to: 'write#editor'
  end

  # API Endpoints
  scope '/generate' do
    # General information

    # Character information
    scope '/character' do
      get '/age',               to: 'characters_generator#age'
      get '/bodytype',          to: 'characters_generator#bodytype'
      get '/eyecolor',          to: 'characters_generator#eyecolor'
      get '/facial-hair',       to: 'characters_generator#facialhair'
      get '/haircolor',         to: 'characters_generator#haircolor'
      get '/hairstyle',         to: 'characters_generator#hairstyle'
      get '/height',            to: 'characters_generator#height'
      get '/identifying-mark',  to: 'characters_generator#identifyingmark'
      get '/name',              to: 'characters_generator#name'
      get '/race',              to: 'characters_generator#race'
      get '/skintone',          to: 'characters_generator#skintone'
      get '/weight',            to: 'characters_generator#weight'
    end

    # Location information
    scope '/location' do
      get '/name',              to: 'locations_generator#name'
    end

    # Equipment location
    scope '/equipment' do
      scope '/weapon' do
        get '/',                to: 'equipment_generator#weapon'

        get '/axe',             to: 'equipment_generator#weapon_axe'
        get '/bow',             to: 'equipment_generator#weapon_bow'
        get '/club',            to: 'equipment_generator#weapon_club'
        get '/fist',            to: 'equipment_generator#weapon_fist'
        get '/flexible',        to: 'equipment_generator#weapon_flexible'
        # TODO: /gun
        get '/polearm',         to: 'equipment_generator#weapon_polearm'
        get '/shortsword',      to: 'equipment_generator#weapon_shortsword'
        get '/sword',           to: 'equipment_generator#weapon_sword'
        get '/thrown',          to: 'equipment_generator#weapon_thrown'
      end

      scope '/armor' do
        get '/',                to: 'equipment_generator#armor'

        get '/shield',          to: 'equipment_generator#armor_shield'
      end
    end
  end

  # Adoption Agency
  scope '/adoption' do
    get '/', to: 'main#comingsoon'
  end

  # Idea Market
  scope '/market' do
    get '/', to: 'main#comingsoon'
  end

  # get '/forum', to: 'emergency#temporarily_disabled'
  # get '/forum/:wildcard', to: 'emergency#temporarily_disabled'
  # get '/forum/:wildcard/:another', to: 'emergency#temporarily_disabled'
  mount Thredded::Engine => '/forum'
  mount StripeEvent::Engine, at: '/webhooks/stripe'

  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.site_administrator? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end

# rubocop:enable LineLength
