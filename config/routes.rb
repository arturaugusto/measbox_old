MeasWeb::Application.routes.draw do
  resources :reports

  resources :report_templates

  resources :kinds

  resources :models do
    collection do
      get :autocomplete
      get :get_json      
    end  
  end

  resources :spreadsheets do
    collection { post :sort }
  end

  resources :manufacturers
  resources :roles

  resources :assets do
    collection do
      get :autocomplete
      get :get_json      
    end
  end

  resources :snippets do
    collection do
      get :autocomplete
      get :get_json      
    end
  end

  resources :companies

  devise_for :users,
           :controllers  => {
             :registrations => 'my_devise/registrations',
             :sessions => "my_devise/sessions",
             :passwords => "my_devise/passwords"
           }
  resources :users do
    post 'invite', :on => :collection
    get 'manage'
    patch 'manage_update'
  end
  #resource :user, only: [:edit] do
  #  collection do
  #    patch 'update_password'
  #  end
  #end  
  #authenticated do
  #  root :to => 'services#index', as: :authenticated
  #end

  #concern :the_role, TheRole::AdminRoutes.new

  #namespace :admin do
  #  concerns :the_role
  #end
  
  resources :services do
    resources :spreadsheets
  end

  resources :spreadsheets do
    collection do
      get :autocomplete
    end
  end

  resources :laboratories
  constraints(Subdomain) do  
    devise_scope :user do
      root to: "my_devise/sessions#new"
    end
  end    
  match '/' => "laboratories#new", via: [:get, :post, :put, :patch, :delete]
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
