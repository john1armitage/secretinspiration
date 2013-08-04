module Permissions
  class OperatorPermission < BasePermission
    def initialize(user)
      allow :choices, :index
      allow :users, [:index, :show, :new, :carts, :edit, :update]
      allow :sessions, [:new, :carts, :destroy]
      allow :items_exists, [:index, :show, :new, :carts, :edit, :update]
      allow_param :user, [:title, :first_name, :last_name, :username, :email]
    end
  end
end