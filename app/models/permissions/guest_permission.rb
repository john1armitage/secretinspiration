module Permissions
  class GuestPermission < BasePermission
    def initialize
      allow :welcome, :index
      allow :choices, [:index,:show]
      allow :pages, [:index, :blog,:show]
      allow :broadcasts, [:index, :blog,:show]
      allow :menus, [:sub,:show]
      allow :carts, [:index, :update, :destroy, :clear]
      allow :line_items, [:create, :update, :destroy]
      allow :sessions, [:new, :create, :carts, :destroy]
      allow :users, [:new, :carts]
      allow :items_exists, [:index, :show]
    end
  end
end