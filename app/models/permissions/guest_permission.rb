module Permissions
  class GuestPermission < BasePermission
    def initialize
      allow :choices, :index
      allow :sessions, [:new, :carts, :destroy]
      allow :users, [:new, :carts]
      allow :items_exists, [:index, :show]
    end
  end
end