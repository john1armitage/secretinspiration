module Permissions
  class GuestPermission < BasePermission
    def initialize
      allow :welcome, :index
      allow :bookings, [:index,:new, :create]
      allow :choices, [:index,:show]
      allow :pages, [:index, :blog,:show]
      allow :broadcasts, [:index, :blog,:show]
      allow :menus, [:sub,:show]
      allow :carts, [:index, :update, :destroy, :clear]
      allow :meals, [:takeaway, :show, :clear, :patcher]
      allow :meal_items, [:create, :update, :destroy]
      allow :line_items, [:create, :update, :destroy]
      allow :sessions, [:new, :create, :carts, :destroy]
      allow :users, [ :carts]
      #allow :users, [:new, :carts]
      allow :items_exists, [:index, :show]
      allow_param :booking, [:walkin, :arrival, :pax, :customer_name, :contact, :notes, :booking_date, :state, :email]
      allow_param :meal, [:contact, :phone, :state]
    end
  end
end