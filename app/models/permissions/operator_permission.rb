module Permissions
  class OperatorPermission < BasePermission
    def initialize(user)
      allow :welcome, :index
      allow :bookings, [:index,:new, :create]
      allow :choices, [:index,:xshow]
      allow :pages, [:index, :blog,:xshow]
      allow :broadcasts, [:index, :blog,:xshow]
      allow :menus, [:sub,:xshow]
      allow :carts, [:index, :update, :clear]
      allow :meals, [:index, :takeaway, :xshow, :clear, :patcher]
      allow :messages, [:index, :create]
      allow :meal_items, [:create, :update, :destroy]
      allow :line_items, [:create, :update, :destroy]
      allow :sessions, [:new, :create, :carts, :destroy]
      allow :users, [ :carts]
      allow_param :booking, [:walkin, :arrival, :pax, :customer_name, :contact, :notes, :booking_date, :state, :email]
      allow_param :meal, [:contact, :phone, :state, :start_time, :notes]
      allow_param :message, [:message, :message_type, :user_id, :create_time]
    end
  end
end