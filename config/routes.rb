# rubocop:disable LineLength
Rails.application.routes.draw do
  # Add password route for devise registrations
  devise_scope :user do
    get 'users/password', to: 'registrations#password', as: 'user_password_edit'
  end
  get 'styleguide/tailwind'
  
  # API routes from master
  namespace :api do
    namespace :v1 do
      post 'gallery_images/sort'
      put 'content/sort', to: 'content#sort'
      get 'categories/suggest/:content_type', to: 'attribute_categories#suggest'
      get 'categories/:id/edit', to: 'attribute_categories#edit'
      get 'fields/suggest/:content_type/:category', to: 'attribute_fields#suggest'
      get 'fields/:id/edit', to: 'attribute_fields#edit'
    end
  end
  default_url_options :host => "notebook.ai"

  scope :ai, path: '/ai' do
    scope :basil do
      # Meta pages
      get '/help/rate',        to: 'basil#help_rate',  as: :basil_rating_queue
      get '/stats',            to: 'basil#stats',      as: :basil_stats
      get '/stats/:page_type', to: 'basil#page_stats', as: :basil_page_stats
      # get '/about',            to: 'basil#about'

      # Admin pages
      get '/review',        to: 'basil#review'

      # API endpoints
      post   '/complete/:jobid', to: 'basil#complete_commission'
      post   '/feedback/:jobid', to: 'basil#feedback', as: :basil_feedback
      post   '/:id/save',        to: 'basil#save',     as: :basil_save
      delete '/:id/delete',      to: 'basil#delete',   as: :basil_delete
      get    '/commission/:jobid', to: 'basil#commission_info', as: :basil_commission_info

      # Landing pages
      get  '/jam',               to: 'basil#jam',        as: :basil_jam
      #post '/jam',               to: 'basil#queue_jam_job', as: :basil_jam_submit

      # Standard generation flow for users
      get  '/',                  to: 'basil#index',      as: :basil
      get  '/:content_type',     to: 'basil#index',      as: :basil_content_index
      get  '/:content_type/:id', to: 'basil#content',    as: :basil_content
      post '/:content_type/:id', to: 'basil#commission', as: :basil_commission
    end

    scope :talk do
      get '/',                      to: 'conversation#character_index',   as: :conversation
      get '/to/:character_id',      to: 'conversation#character_landing', as: :talk
      post '/export/:character_id', to: 'conversation#export',            as: :export_character
    end
  end

  # Temporary landing path for jams (nice URL)
  get '/jam', to: 'basil#jam', as: :jam

  scope :stream, path: '/stream', as: :stream do
    get '/',         to: 'stream#index'
    get 'world',     to: 'stream#global'
    get 'community', to: 'stream#community'
  end
  resources :page_collections, path: '/collections' do
    get '/submissions', to: 'page_collection_submissions#index', as: 'pending_submissions'
    get '/explore',     to: 'page_collections#explore',          on: :collection
    Rails.application.config.content_types[:all].each do |content_type|
      get content_type.name.downcase.pluralize.to_sym, on: :member
    end
    get 'follow',   on: :member
    get 'unfollow', on: :member
    get 'report',   on: :member
    get 'rss',      on: :member, defaults: { format: 'rss' }
    get 'feed',     on: :member, to: 'page_collections#rss', defaults: { format: 'rss' }, as: 'feed'
    get 'pages',    on: :member, to: 'page_collections#pages', defaults: { format: 'json' }

    get 'by/:user_id', to: 'page_collections#by_user', as: :submissions_by_user
    
    # Editor picks management
    get 'editor_picks', to: 'page_collection_editor_picks#index', as: 'manage_editor_picks'
    resources :editor_picks, controller: 'page_collection_editor_picks', except: [:show, :edit]
  end
  resources :page_collection_submissions do
    get 'approve', on: :member
    get 'pass',    on: :member
  end

  get 'notice_dismissal/dismiss'
  resources :notifications
  # TODO this should probably be a POST or something
  get '/mark_all_read', to: 'notifications#mark_all_read'
  resources :share_comments

  get 'customization/content_types'
  post 'customization/toggle_content_type'

  # User-centric stuff
  devise_for :users, :controllers => { registrations: 'registrations', sessions: 'sessions' }
  resources :users do
    devise_scope :user do
      get 'preferences',  to: 'registrations#preferences'
      get 'more_actions', to: 'registrations#more_actions'
    end

    get 'followers', on: :member
    get 'following', on: :member

    # get :characters, on: :member <...etc...>
    Rails.application.config.content_types[:all].each do |content_type|
      get content_type.name.downcase.pluralize.to_sym, on: :member
      # todo page tags here
    end

    resources :content_page_shares, path: 'shares' do
      get 'follow',   on: :member
      get 'unfollow', on: :member
      get 'report',   on: :member
    end
  end
  resources :user_followings
  resources :user_blockings

  # Username URL aliases
  get '/@:username', to: 'users#show', as: :profile_by_username
  get '/@:username/followers', to: 'users#followers'
  get '/@:username/following', to: 'users#following'
  get '/@:username/tag/:tag_slug', to: 'users#tag', as: :user_tag
  
  # ID-based alternative routes for users without usernames
  get '/users/:id/tag/:tag_slug', to: 'users#tag', as: :user_id_tag

  scope '/analysis' do
    get '/', to: 'document_analyses#landing', as: :landing_path
    get '/hub', to: 'document_analyses#hub', as: :analysis_hub
  end

  resources :documents do
    # Document Analysis routes
    get '/analysis/',            to: 'document_analyses#show',        on: :member      
    get '/analysis/readability', to: 'document_analyses#readability', on: :member
    get '/analysis/style',       to: 'document_analyses#style',       on: :member
    get '/analysis/sentiment',   to: 'document_analyses#sentiment',   on: :member
    get  '/plaintext',           to: 'documents#plaintext',               on: :member
    get  '/queue_analysis',      to: 'documents#queue_analysis',          on: :member

    resources :document_revisions, path: 'revisions', on: :member

    get '/tagged/:slug', action: :index, on: :collection, as: :page_tag

    post :toggle_favorite, on: :member

    # todo these routes don't belong here and make for awfully weird urls (/documents/:analysis_id/destroy, etc)
    get  '/destroy_analysis', to: 'documents#destroy_analysis',        on: :member

    post '/link_entity',         to: 'documents#link_entity',          on: :collection
    # deprecated route:
    get  '/destroy_entity',   to: 'documents#destroy_document_entity', on: :member
    # new route:
    get  '/unlink/:page_type/:page_id', to: 'documents#unlink_entity', on: :member
  end
  resources :folders, only: [:create, :update, :destroy, :show]

  scope '/my' do
    get '/dashboard',       to: 'main#dashboard', as: :dashboard
    get '/content',         to: 'main#table_of_contents', as: :table_of_contents
    get '/content/recent',  to: 'main#recent_content', as: :recent_content
    get '/content/deleted', to: 'content#deleted', as: :recently_deleted_content
    get '/prompts',         to: 'main#prompts', as: :prompts

    get '/multiverse',      to: 'universes#hub', as: :multiverse

    get '/scratchpad',      to: 'main#notes', as: :notes

    get 'tag/remove',         to: 'page_tags#remove'
    # post 'tag/:slug/update',  to: 'page_tags#update',  as: :update_tag
    post '/tag/:tag/rename', to: 'page_tags#rename', as: :rename_tag
    delete 'tag/:id/destroy', to: 'page_tags#destroy', as: :destroy_specific_tag

    # Legacy route: left intact so /my/documents/X URLs continue to work for everyone's bookmarks
    resources :documents


    get '/referrals',          to: 'data#referrals', as: :referrals

    # Billing
    scope '/billing' do
      #get '/',             to: 'subscriptions#show', as: :billing
      get '/subscription',       to: 'subscriptions#new', as: :subscription
      get '/history',            to: 'subscriptions#history', as: :billing_history

      get '/to/:stripe_plan_id', to: 'subscriptions#change', as: :change_subscription

      get '/information',        to: 'subscriptions#information',        as: :payment_info
      post '/information',       to: 'subscriptions#information_change', as: :process_payment_info

      # This should probably be a DELETE
      get '/payment_method/delete', to: 'subscriptions#delete_payment_method', as: :delete_payment_method

      # Promotional codes & sharing
      post '/redeem',    to: 'subscriptions#redeem_code'
      get '/gift/:code', to: 'subscriptions#redeem', as: :gift_code

      # Prepaying for subscriptions
      get '/prepay',                    to: 'subscriptions#prepay', as: :prepay
      get '/prepay/paid',               to: 'subscriptions#prepay_paid'
      get '/prepay_redirect_to_paypal', to: 'subscriptions#prepay_redirect_to_paypal', as: :prepay_paypal_gateway
    end

    # TODO delete deprecated/unused referrals controller/views

    scope '/data' do
      get '/',              to: 'data#index',     as: :data_vault
      get '/usage',         to: 'data#usage'
      get '/tags',          to: 'data#tags'
      get '/recyclebin',    to: 'data#recyclebin'
      get '/archive',       to: 'data#archive'
      get '/documents',     to: 'data#documents', as: :data_documents
      get '/uploads',       to: 'data#uploads'
      get '/discussions',   to: 'data#discussions'
      get '/collaboration', to: 'data#collaboration'
      get '/green',         to: 'data#green'
      get '/achievements',  to: 'data#achievements', as: :achievements
      scope 'yearly' do
        get '/',      to: 'data#yearly_index',   as: :year_in_review
        get '/:year', to: 'data#review_year',    as: :review_year
      end

      scope 'export' do
        get '/', to: 'export#index', as: :notebook_export
    
        get '/outline',       to: 'export#outline',       as: :notebook_outline
        get '/markdown',      to: 'export#markdown',      as: :notebook_markdown
        get '/notebook.json', to: 'export#notebook_json', as: :notebook_json
        get '/notebook.xml',  to: 'export#notebook_xml',  as: :notebook_xml
        get '/notebook.yml',  to: 'export#notebook_yml',  as: :notebook_yml
        get '/:model.csv',    to: 'export#csv',           as: :notebook_csv
      end
    end
  end
  delete 'delete_my_account', to: 'users#delete_my_account'
  delete 'contributor/:id/remove', to: 'contributors#destroy', as: :remove_contributor
  post 'universes/:universe_id/contributors', to: 'contributors#create', as: :universe_contributors
  get '/unsubscribe/emails/:code', to: 'emails#one_click_unsubscribe'

  get '/paper', to: redirect('https://www.notebook-paper.com')

  # Help Center - Public routes
  get '/help', to: 'help#index', as: :help_center
  get '/help/your-first-universe', to: 'help#your_first_universe', as: :help_your_first_universe
  get '/help/page-visualization', to: 'help#page_visualization', as: :help_page_visualization
  get '/help/document-analysis', to: 'help#document_analysis', as: :help_document_analysis
  get '/help/organizing-with-tags', to: 'help#organizing_with_tags', as: :help_organizing_with_tags
  get '/help/page-templates', to: 'help#page_templates', as: :help_page_templates
  get '/help/organizing-with-universes', to: 'help#organizing_with_universes', as: :help_organizing_with_universes
  get '/help/premium-features', to: 'help#premium_features', as: :help_premium_features
  get '/help/free-features', to: 'help#free_features', as: :help_free_features

  # Main pages
  root to: 'main#index'

  # Info pages
  scope '/about' do
    get '/paper',       to: 'main#paper',       as: :green_paper
    get '/privacy',     to: 'main#privacyinfo', as: :privacy_policy
    get '/billing/faq', to: 'subscriptions#faq'
  end

  # Landing pages
  scope '/for' do
    get '/writers',     to: 'main#for_writers',     as: :writers_landing
    get '/roleplayers', to: 'main#for_roleplayers', as: :roleplayers_landing
  end

  # Lab apps
  scope '/lab' do
    # Navigator
    get 'navigator', to: 'navigator#index'

    # Babel
    get 'babel',     to: 'lab#babel'
    post 'babel',    to: 'lab#babel'

    # Pinboard
    get 'pinboard',  to: 'lab#pinboard'

    get 'dice', to: 'lab#dice'
    get 'crossword', to: 'lab#crossword'
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
      get :timelines, on: :member

      get  :changelog,       on: :member
      # Redirect old gallery URLs to the show page with #gallery hash
      get  :gallery,         on: :member, to: redirect { |params, req| "/plan/#{params[:controller].split('/').last}/#{params[:id]}#gallery" }
      get  :toggle_archive,  on: :member
      post :toggle_favorite, on: :member
      get '/tagged/:slug', action: :index, on: :collection, as: :page_tag
    end
    Rails.application.config.content_types[:all_non_universe].each do |content_type|
      # Skip Timeline since it has its own explicit routes below
      next if content_type.name == 'Timeline'
      
      # resources :characters do
      resources content_type.name.downcase.pluralize.to_sym do

        # Browsable pages
        # Redirect old gallery URLs to the show page with #gallery hash
        get  :gallery,         on: :member, to: redirect { |params, req| "/plan/#{params[:controller].split('/').last}/#{params[:id]}#gallery" }
        get  :references,      on: :member
        get  :changelog,       on: :member
        get '/tagged/:slug',   on: :collection, action: :index, as: :page_tag

        # API endpoints
        get  :toggle_archive,  on: :member
        post :toggle_favorite, on: :member
        # Already have these routes above, no need to duplicate
      end
    end
    resources :timelines, only: [:index, :show, :new, :update, :edit, :destroy] do
      get '/tagged/:slug', action: :index, on: :collection, as: :page_tag
      get 'tag_suggestions', to: 'timelines#tag_suggestions', on: :member
      get :toggle_archive, on: :member
    end
    resources :timeline_events do
      scope '/move', as: :move do
        get 'up',     to: 'timeline_events#move_up',        on: :member
        get 'down',   to: 'timeline_events#move_down',      on: :member
        get 'top',    to: 'timeline_events#move_to_top',    on: :member
        get 'bottom', to: 'timeline_events#move_to_bottom', on: :member
      end
      post 'link',              to: 'timeline_events#link_entity',    on: :member
      post 'unlink/:entity_id', to: 'timeline_events#unlink_entity',  on: :member, as: :unlink_entity
      post 'tags',              to: 'timeline_events#add_tag',        on: :member, as: :add_tag
      delete 'tags/:tag_name',  to: 'timeline_events#remove_tag',     on: :member, as: :remove_tag
    end

    # Content attributes
    resources :attribute_categories, only: [:create, :update, :destroy, :edit] do
      get :suggest, on: :collection
    end
    resources :attribute_fields,     only: [:create, :update, :destroy, :edit] do
      get :suggest, on: :collection
    end

    # Image handling
    delete '/delete/image/:id', to: 'image_upload#delete', as: :image_deletion
    post '/toggle_image_pin', to: 'content#toggle_image_pin', as: :toggle_image_pin

    # Attributes
    get ':content_type/attributes', to: 'content#attributes', as: :attribute_customization
    get ':content_type/template/export', to: 'content#export_template', as: :export_template
    delete ':content_type/template/reset', to: 'content#reset_template', as: :reset_template
  end

  # For non-API API endpoints
  scope :internal do
    patch '/link_field_update/:field_id',     to: 'content#link_field_update',     as: :link_field_update
    patch '/name_field_update/:field_id',     to: 'content#name_field_update',     as: :name_field_update
    patch '/text_field_update/:field_id',     to: 'content#text_field_update',     as: :text_field_update
    patch '/tags_field_update/:field_id',     to: 'content#tags_field_update',     as: :tags_field_update
    patch '/universe_field_update/:field_id', to: 'content#universe_field_update', as: :universe_field_update
    patch '/sort/categories',                 to: 'attribute_categories#sort',     as: :sort_categories_internal
    patch '/sort/fields',                     to: 'attribute_fields#sort',         as: :sort_fields_internal
    patch '/sort/timeline_events',            to: 'timeline_events#sort',          as: :sort_timeline_events_internal
  end

  get 'search/', to: 'search#results'
  get 'search/autocomplete', to: 'search#autocomplete'

  authenticate :user, lambda { |u| u.site_administrator? || Rails.env.development? } do
    scope 'admin' do
      get '/stats',                to: 'admin#dashboard', as: :admin_dashboard
      get '/content_type/:type',   to: 'admin#content_type', as: :admin_content_type
      get '/attributes',           to: 'admin#attributes', as: :admin_attributes
      get '/masquerade/:user_id',  to: 'admin#masquerade', as: :masquerade
      get '/unsubscribe',          to: 'admin#unsubscribe', as: :mass_unsubscribe
      get '/images',               to: 'admin#images', as: :image_audit
      get '/promos',               to: 'admin#promos', as: :admin_promos
      get '/shares/reported',      to: 'admin#reported_shares'
      get '/churn',                to: 'admin#churn'
      get '/hatewatch/:matchlist', to: 'admin#hate'
      get '/spamwatch',            to: 'admin#spam'
      get '/notifications',        to: 'admin#notifications'
      post '/perform_unsubscribe', to: 'admin#perform_unsubscribe', as: :perform_unsubscribe
    end
    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  end

  # Browse global content routes
  scope '/browse' do
    get '/tag/:tag_slug', to: 'browse#tag', as: :browse_tag
  end

  # Fancy shmancy informative pages
  scope '/worldbuilding' do
    Rails.application.config.content_types[:all].each do |content_type|
      get content_type.name.downcase.pluralize, to: "information##{content_type.name.downcase.pluralize}", as: "#{content_type.name.downcase}_worldbuilding_info"
      # TODO: documents info page
      # TODO: timelines info page
    end
  end

  scope '/scene/:scene_id' do
    get 'editor', to: 'write#editor'
  end

  # API Endpoints
  get '/platform', to: 'api_docs#index'
  namespace :api do
    resources :application_integrations, path: :applications, as: :applications do
      get '/authorize',    action: :authorize,    on: :member
    end

    scope '/authorizations' do
      post '/create', to: 'integration_authorizations#create', as: :integration_authorizations
    end
      
    get '/',             to: 'api_docs#index'
    get '/docs',         to: 'api_docs#docs'
    # get '/applications', to: 'api_docs#applications'
    get '/approvals',    to: 'api_docs#approvals'
    get '/integrations', to: 'api_docs#integrations'
    get '/pricing',      to: 'api_docs#pricing'
    
    scope 'docs' do
      get '/',           to: 'api_docs#index'
      get '/references', to: 'api_docs#references'
    end

    # API requests we don't want to officially make public -- free to break!
    namespace :internal do
      get '/:page_type/:page_id/name',            to: 'api#name_lookup'
    end

    namespace :v1 do
      scope '/categories' do
        get '/suggest/:entity_type',              to: 'attribute_categories#suggest'
      end
      scope '/fields' do
        get '/suggest/:entity_type/:category',    to: 'attribute_fields#suggest'
        get '/:id/edit',                         to: 'attributes#field_edit'
      end
      scope '/categories' do
        get '/suggest/:entity_type',              to: 'attribute_categories#suggest'
        get '/:id/edit',                         to: 'attributes#category_edit'
      end
      scope '/content' do
        put '/sort',                             to: 'attributes#sort'
      end
      scope '/answers' do
        get '/suggest/:entity_type/:field_label', to: 'attributes#suggest'
      end
      
      # Page name lookup
      get '/page_name', to: 'page_names#show'

      # Content index path
      Rails.application.config.content_types[:all].each do |content_type|
        get "#{content_type.name.downcase.pluralize}", to: "api##{content_type.name.downcase.pluralize}"
      end
      get :timelines, to: "api#timelines"

      # Content show paths
      Rails.application.config.content_types[:all].each do |content_type|
        get "#{content_type.name.downcase}/:id", to: "api##{content_type.name.downcase}"
      end
      get "timeline/:id", to: "api#timeline"
    end
  end

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

  # get '/forum', to: 'emergency#temporarily_disabled'
  # get '/forum/:wildcard', to: 'emergency#temporarily_disabled'
  # get '/forum/:wildcard/:another', to: 'emergency#temporarily_disabled'
  mount Thredded::Engine,    at: '/forum',                           as: :thredded
  get '/topic/:slug',        to: 'thredded_proxy#topic',             as: :topic
  get '/plaintext/:slug',    to: 'thredded_proxy#view_as_plaintext', as: :plaintext_topic
  get '/irc_log/:slug',      to: 'thredded_proxy#view_as_irc_log',   as: :irc_log_topic
  get '/save/:slug',         to: 'thredded_proxy#save_to_document',  as: :documentize_topic

  mount StripeEvent::Engine, at: '/webhooks/stripe'

  # Sidekiq Web UI with authentication for v7+
  require 'sidekiq/web'
  
  # Use Devise authentication constraint
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect with simple authentication until we can fix proper user-based auth
    # This is a temporary solution until we update the authentication to use ActiveSupport::SecurityUtils
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_USERNAME'] || 'admin')) &
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_PASSWORD'] || 'password'))
  end unless Rails.env.development?

  mount Sidekiq::Web => '/sidekiq'

  # Promos and other temporary pages
  get '/redeem/infostack', to: 'main#infostack'
  get '/redeem/sascon',    to: 'main#sascon'
end
