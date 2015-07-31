Commerce::Application.routes.draw do

  resources :financials do
    collection do
      get 'batch'
      get 'processor'
    end
  end

  resources :monthlies

  resources :wages

  resources :pay_rates

  resources :offers

  resources :dailies

  resources :timesheets

  resources :openings

  resources :topics

  resources :pages do
    collection do
      get 'blog'
    end
  end

  resources :broadcasts do
    collection do
      get 'blog'
    end
  end

  resources :employees

  resources :receipts

  root 'welcome#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  delete 'logout', to: 'sessions#destroy', as: 'logout'

  #get 'choices', to: 'choices#index', as: 'choices'
  resources :choices, :only => [ :index, :show ]

  resources :messages, :only => [ :index, :create, :destroy ]

  resources :users
  resources :roles, :only => [ :index, :create, :destroy ]

  resources :sessions
  resources :password_resets
  resources :elements
  resources :item_types
  resources :item_fields
  resources :tenancies
  resources :menus, :only => [:show] do
    member do
      get 'sub'
    end
  end
  resources :categories
  resources :accounts

  resources :carts, :only => [:index, :update, :show, :destroy] do
    member do
      post 'check_out'
      post 'check_in'
      delete 'clear'
    end
  end

  resources :meals, :only => [:index, :create, :show, :edit, :update, :destroy] do
    member do
      get 'takeaway'
      post 'check_out'
      post 'check_in'
      post 'patcher'
      delete 'clear'
    end
  end

  resources :meal_items do
    member do
      get 'special'
    end
  end
  resources :line_items
  resources :items
  resources :variants
  resources :pics
  resources :options

  resources :bookings do
    member do
      post 'status'
    end
    collection do
      get 'dated'
    end
  end
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
      post 'status'
    end
    collection do
      get 'analysis'
    end
  end
  resources :transfers do
    member do
      post 'commit'
    end
  end
  resources :payments
  resources :postings, :only => [:index, :show] do
    collection do
      match 'search' => 'collections#search', via: [:get, :post], as: :search
    end
  end
  get 'choices', to: 'choices#index'
  get 'welcome', to: 'welcome#index'
  get 'enchant', to: 'enchant#index'

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
