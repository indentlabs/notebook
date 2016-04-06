PlanCharacters::Application.routes.draw do
  devise_for :users
  # rubocop:disable LineLength

  # Main pages
  root to: 'main#index'

  # Info pages
  scope '/about' do
    get '/anon-login', to: 'main#anoninfo',    as: :anon_info
    get '/privacy',    to: 'main#privacyinfo', as: :privacy_info
    get '/attribution', to: 'main#attribution', as: :attribution_info
  end

  # User-centric stuff
  scope '/my' do
    get '/content',     to: 'main#dashboard', as: :dashboard
    get '/submissions', to: 'main#comingsoon'
  end

  # Sessions
  get '/login',  to: 'sessions#new',     as: :login
  post '/login',  to: 'sessions#create',  as: :login_process
  get '/logout', to: 'sessions#destroy', as: :logout

  # Planning
  scope '/plan' do
    # Characters
    get '/characters',         to: 'characters#index',   as: :character_list
    get '/characters/from/:universe', to: 'characters#index', as: :characters_by_universe
    get '/character/new',      to: 'characters#new',     as: :character_create
    post '/character/new',      to: 'characters#create',  as: :character_create_process
    get '/character/:id',      to: 'characters#show',    as: :character
    get '/character/:id/edit', to: 'characters#edit',    as: :character_edit
    patch '/character/:id',      to: 'characters#update',  as: :character_edit_process
    delete '/character/:id',      to: 'characters#destroy', as: :character_destroy

    # Items
    get '/items',          to: 'equipment#index',   as: :item_list
    get '/items/from/:universe', to: 'equipment#index', as: :item_by_universe
    get '/item/new',      to: 'equipment#new',     as: :item_create
    get '/item/new/:type_of', to: 'equipment#new',     as: :item_create_type
    post '/item/new',      to: 'equipment#create',  as: :item_create_process
    get '/item/:id',      to: 'equipment#show',    as: :item
    get '/item/:id/edit', to: 'equipment#edit',    as: :item_edit
    patch '/item/:id',      to: 'equipment#update',  as: :item_edit_process
    delete '/item/:id',      to: 'equipment#destroy', as: :item_destroy

    # Locations
    get '/locations',         to: 'locations#index',   as: :location_list
    get '/locations/from/:universe', to: 'locations#index', as: :locations_by_universe
    get '/location/new',      to: 'locations#new',     as: :location_create
    post '/location/new',      to: 'locations#create',  as: :location_create_process
    get '/location/new/:type_of', to: 'locations#new',     as: :location_create_type
    get '/location/:id',      to: 'locations#show',    as: :location
    get '/location/:id/edit', to: 'locations#edit',    as: :location_edit
    patch '/location/:id',      to: 'locations#update',  as: :location_edit_process
    delete '/location/:id',      to: 'locations#destroy', as: :location_destroy

    # Universes
    get '/universes',         to: 'universes#index',   as: :universe_list
    get '/universe/new',      to: 'universes#new',     as: :universe_create
    post '/universe/new',      to: 'universes#create',  as: :universe_create_process
    get '/universe/:id',      to: 'universes#show',    as: :universe
    get '/universe/:id/edit', to: 'universes#edit',    as: :universe_edit
    patch '/universe/:id',      to: 'universes#update',  as: :universe_edit_process
    delete '/universe/:id',      to: 'universes#destroy', as: :universe_destroy

    # Coming Soon TM
    get '/plots',     to: 'main#comingsoon'
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

  # Write
  scope '/write' do
    get '/lyrics',     to: 'main#comingsoon'
    get '/novel',      to: 'main#comingsoon'
    get '/nonfiction', to: 'main#comingsoon'
    get '/poetry',     to: 'main#comingsoon'
    get '/screenplay', to: 'main#comingsoon'
    get '/story',      to: 'main#comingsoon'
  end

  # Revise
  scope '/revise' do
    get '/checklists',          to: 'main#comingsoon'
    get '/analytics',           to: 'main#comingsoon'
    get '/peer-critiques',      to: 'main#comingsoon'
    get '/professional-review', to: 'main#comingsoon'
  end

  # Submit
  scope '/submit' do
    get '/blog',              to: 'main#comingsoon'
    get '/print-publishers',  to: 'main#comingsoon'
    get '/online-publishers', to: 'main#comingsoon'
  end

  # rubocop:enable LineLength
end
