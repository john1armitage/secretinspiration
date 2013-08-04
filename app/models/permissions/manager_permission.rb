module Permissions
  class ManagerPermission < BasePermission
    def initialize(user)
      allow :choices, :index
      allow :users, [:new, :carts, :edit, :update]
      allow :sessions, [:new, :carts, :destroy]
      allow :items_exists, [:index, :show, :new, :carts, :edit, :update]
    end
  end
end