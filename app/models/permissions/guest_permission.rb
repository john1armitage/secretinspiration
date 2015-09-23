module Permissions
  class GuestPermission < BasePermission
    def initialize
      allow :welcome, [:index, :edit, :update]
      allow :bookings, [:index,:new, :create]
      allow :choices, [:index,:xshow]
      allow :pages, [:index, :blog,:xshow]
      allow :broadcasts, [:index, :blog,:xshow]
      allow :menus, [:sub,:xshow]
      allow :carts, [:index, :update, :clear]
      allow :meals, [:takeaway, :xshow, :clear, :patcher]
      allow :meal_items, [:create, :update, :destroy]
      allow :line_items, [:create, :update, :destroy]
      allow :sessions, [:new, :create, :carts, :destroy]
      allow :users, [ :carts]
      allow_param :booking, [:walkin, :arrival, :pax, :customer_name, :contact, :notes, :booking_date, :state, :email]
      allow_param :meal, [:contact, :phone, :state, :start_time, :notes]
    end
  end
end