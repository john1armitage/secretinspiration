module Permissions
  class UserPermission < BasePermission
    def initialize(user)
      allow :choices, :index
      allow :sessions, [:new, :carts, :destroy]
      allow :items_exists, [:index, :show]
      allow :users, [:show, :form, :update] do |u|
        u.id == user.id
      end
      allow_param :user, [:title, :first_name, :last_name, :email]
    end
  end
end