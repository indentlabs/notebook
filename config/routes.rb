# rubocop:disable LineLength

Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :users

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

    get '/friends', to: 'main#for_friends', as: :friends_landing
  end

  scope '/vote' do
    get '/community', to: 'main#feature_voting', as: :community_voting
  end

  # User-centric stuff
  scope '/my' do
    get '/content',     to: 'main#dashboard', as: :dashboard
    get '/content/recent', to: 'main#recent_content', as: :recent_content
    get '/submissions', to: 'main#comingsoon'
    get '/prompts', to: 'main#prompts', as: :prompts

    # Billing
    scope '/billing' do
      #get '/',             to: 'subscriptions#show', as: :billing
      get '/subscription',       to: 'subscriptions#new', as: :subscription

      get '/to/:stripe_plan_id', to: 'subscriptions#change', as: :change_subscription

      get '/information',        to: 'subscriptions#information',        as: :payment_info
      post '/information',       to: 'subscriptions#information_change', as: :process_payment_info

      # This should probably be a DELETE
      get '/payment_method/delete', to: 'subscriptions#delete_payment_method', as: :delete_payment_method
    end
  end

  # Sessions
  get '/login', to: 'sessions#new', as: :login
  post '/login', to: 'sessions#create', as: :login_process
  get '/logout', to: 'sessions#destroy', as: :logout

  # Planning
  scope '/plan' do
    # Core content types
    resources :universes
    resources :characters do
      get :autocomplete_character_name, on: :collection, as: :autocomplete_name
    end
    resources :items
    resources :locations do
      get :autocomplete_location_name, on: :collection, as: :autocomplete_name
    end

    # Extended content types
    resources :creatures
    resources :races
    resources :religions
    resources :magics
    resources :languages

    # Content usage
    resources :scenes
    resources :groups

    # Content attributes
    resources :attributes
    resources :attribute_categories
    resources :attribute_fields

    # Image handling
    delete '/delete/image/:id', to: 'image_upload#delete', as: :image_deletion

    # Coming Soon TM
    get '/plots',     to: 'main#comingsoon'
  end

  scope 'admin' do
    get '/', to: 'admin#dashboard', as: :admin_dashboard
    get '/attributes', to: 'admin#attributes', as: :admin_attributes
    get '/universes', to: 'admin#universes', as: :admin_universes
    get '/characters', to: 'admin#characters', as: :admin_characters
    get '/locations', to: 'admin#locations', as: :admin_locations
    get '/items', to: 'admin#items', as: :admin_items
  end

  scope 'export' do
    get '/', to: 'export#index', as: :notebook_export

    get '/outline', to: 'export#outline', as: :notebook_outline
    get '/notebook.json', to: 'export#notebook_json', as: :notebook_json
    get '/notebook.xml', to: 'export#notebook_xml', as: :notebook_xml

    get '/universes.csv', to: 'export#universes_csv', as: :universes_csv
    get '/characters.csv', to: 'export#characters_csv', as: :characters_csv
    get '/locations.csv', to: 'export#locations_csv', as: :locations_csv
    get '/items.csv', to: 'export#items_csv', as: :items_csv
    get '/creatures.csv', to: 'export#creatures_csv', as: :creatures_csv
    get '/races.csv', to: 'export#races_csv', as: :races_csv
    get '/religions.csv', to: 'export#religions_csv', as: :religions_csv
    get '/magics.csv', to: 'export#magics_csv', as: :magics_csv
    get '/languages.csv', to: 'export#languages_csv', as: :languages_csv
    get '/scenes.csv', to: 'export#scenes_csv', as: :scenes_csv
    get '/groups.csv', to: 'export#groups_csv', as: :groups_csv
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
end

# rubocop:enable LineLength
