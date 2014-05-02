module Permissions
  class ManagerPermission < BasePermission
    def initialize(user)
      allow :choices, :index
      allow :users, [:new, :carts, :form, :update]
      allow :sessions, [:new, :carts, :destroy]
      allow :items_exists, [:index, :show, :new, :carts, :form, :update]
      allow :welcome, :index
      allow :bookings, [:index,:new, :create]
      allow :choices, [:index,:show]
      allow :pages, [:index, :blog,:show]
      allow :broadcasts, [:index, :blog,:show]
      allow :menus, [:sub,:show]
      allow :carts, [:index, :update, :clear]
      allow :meals, [:takeaway, :show, :clear, :patcher]
      allow :meal_items, [:create, :update, :destroy]
      allow :line_items, [:create, :update, :destroy]
      allow :sessions, [:new, :create, :carts, :destroy]
      allow :users, [ :carts]
      allow_param :booking, [:walkin, :arrival, :pax, :customer_name, :contact, :notes, :booking_date, :state, :email]
      allow_param :meal, [:contact, :phone, :state, :start_time, :notes]
    end
  end
end