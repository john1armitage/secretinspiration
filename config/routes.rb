Commerce::Application.routes.draw do

  resources :employees

  resources :receipts

  root 'choices#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  delete 'logout', to: 'sessions#destroy', as: 'logout'

  get 'choices', to: 'choices#index', as: 'choices'


  resources :users
  resources :roles, :only => [ :index, :create, :destroy ]

  resources :sessions
  resources :password_resets
  resources :elements
  resources :item_types
  resources :item_fields
  resources :tenancies
  resources :menus, :only => :show
  resources :categories
  resources :accounts

  resources :carts, :only => [:index, :update, :destroy] do
    collection do
      delete 'clear'
    end
  end

  resources :meals, :only => [:index, :create, :show, :edit, :update, :destroy] do
    member do
      post 'check_out'
      delete 'clear'
    end
  end

  resources :meal_items
  resources :line_items
  resources :items
  resources :variants
  resources :pics
  resources :options

  resources :bookings
  resources :tabels

  resources :suppliers do
    member do
      post 'pay'
    end
  end
  resources :banks
  resources :customers
  resources :orders do
    member do
      post 'commit'
    end
  end
  resources :transfers do
    member do
      post 'commit'
    end
  end
  resources :payments
  resources :postings, :only => [:index, :show]

  get 'choices', to: 'choices#index'
  get 'welcome', to: 'welcome#index'

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
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ItemsExistsController
  #     # (app/controllers/admin/items_exists_controller.rb)
  #     resources :products
  #   end
end
