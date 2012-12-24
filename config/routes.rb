PlanCharacters::Application.routes.draw do

  # Main pages
  root :to => 'main#index', :as => :homepage
  
  # Sessions
  get  '/login',  :to => 'sessions#new',     :as => :login
  post '/login',  :to => 'sessions#create',  :as => :login_process
  get  '/logout', :to => 'sessions#destroy', :as => :logout

  # Users
  get  '/register', :to => 'users#new',    :as => :signup
  post '/register', :to => 'users#create', :as => :signup_process
  get  '/account',  :to => 'users#edit',   :as => :account
  put  '/account',  :to => 'users#update', :as => :account_process
  
  # Characters
  get    '/characters',         :to => 'characters#index',   :as => :character_list
  get    '/character/:id',      :to => 'characters#show',    :as => :character
  get    '/character/:id/edit', :to => 'characters#edit',    :as => :character_edit
  put    '/character/:id',      :to => 'characters#update',  :as => :character_edit_process
  get    '/characters/new',     :to => 'characters#new',     :as => :character_create
  post   '/characters/new',     :to => 'characters#create',  :as => :character_create_process
  delete '/character/:id',      :to => 'characters#destroy', :as => :character_destroy

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
