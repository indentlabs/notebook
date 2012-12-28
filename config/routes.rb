PlanCharacters::Application.routes.draw do

  # Main pages
  root :to => 'main#index', :as => :homepage
  
  # User-centric stuff
  scope '/my' do
  	get '/content',     :to => 'main#comingsoon'
  	get '/submissions', :to => 'main#comingsoon'
  end
  
  # Sessions
  get  '/login',  :to => 'sessions#new',     :as => :login
  post '/login',  :to => 'sessions#create',  :as => :login_process
  get  '/logout', :to => 'sessions#destroy', :as => :logout

  # Users
  get  '/register',     :to => 'users#new',    :as => :signup
  post '/register',     :to => 'users#create', :as => :signup_process
  get  '/account',      :to => 'users#edit',   :as => :account
  put  '/register',     :to => 'users#update', :as => :account_process
  get  '/be-anonymous', :to => 'users#anonymous', :as => :anonymous
  
  # Planning
  scope '/plan' do
		# Characters
		get    '/characters',         :to => 'characters#index',   :as => :character_list
		get    '/character/new',      :to => 'characters#new',     :as => :character_create
		post   '/character/new',      :to => 'characters#create',  :as => :character_create_process
		get    '/character/:id',      :to => 'characters#show',    :as => :character
		get    '/character/:id/edit', :to => 'characters#edit',    :as => :character_edit
		put    '/character/:id',      :to => 'characters#update',  :as => :character_edit_process
		delete '/character/:id',      :to => 'characters#destroy', :as => :character_destroy
		
		# Equipment
		get    '/equipment',          :to => 'equipment#index',   :as => :equipment_list
		get    '/equipment/new',      :to => 'equipment#new',     :as => :equipment_create
		post   '/equipment/new',      :to => 'equipment#create',  :as => :equipment_create_process
		get    '/equipment/:id',      :to => 'equipment#show',    :as => :equipment
		get    '/equipment/:id/edit', :to => 'equipment#edit',    :as => :equipment_edit
		put    '/equipment/:id',      :to => 'equipment#update',  :as => :equipment_edit_process
		delete '/equipment/:id',      :to => 'equipment#destroy', :as => :equipment_destroy
		
		# Coming Soon TM
		get '/languages', :to => 'main#comingsoon'
		get '/locations', :to => 'main#comingsoon'
		get '/magic',     :to => 'main#comingsoon'
		get '/plots',     :to => 'main#comingsoon'
	end
	
	# Adoption Agency
	scope '/adoption' do
		get '/', :to => 'main#comingsoon'
	end
	
  # Write
  scope '/write' do
  	get '/lyrics',     :to => 'main#comingsoon'
  	get '/novel',      :to => 'main#comingsoon'
  	get '/nonfiction', :to => 'main#comingsoon'
  	get '/poetry',     :to => 'main#comingsoon'
  	get '/screenplay', :to => 'main#comingsoon'
  	get '/story',      :to => 'main#comingsoon'
  end
  
  # Revise
  scope '/revise' do
  	get '/checklists',          :to => 'main#comingsoon'
  	get '/analytics',           :to => 'main#comingsoon'
  	get '/peer-critiques',      :to => 'main#comingsoon'
  	get '/professional-review', :to => 'main#comingsoon'
  end
  
  # Submit
  scope '/submit' do
  	get '/blog',              :to => 'main#comingsoon'
  	get '/print-publishers',  :to => 'main#comingsoon'
  	get '/online-publishers', :to => 'main#comingsoon'
  end

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
