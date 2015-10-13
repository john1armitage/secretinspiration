module Permissions
  class OperatorPermission < BasePermission
    def initialize(user)
      allow :welcome, :index
      allow :bookings, [:index,:new, :create]
      allow :items, [:index, :update]
      allow :stocks, [:index, :destroy]
      allow :choices, [:index,:show]
      allow :pages, [:index, :blog,:show]
      allow :broadcasts, [:index, :blog,:show]
      allow :menus, [:sub,:show]
      allow :orders, [:analysis]
      allow :carts, [:index, :update, :clear]
      allow :meals, [:index, :takeaway, :show, :clear, :patcher]
      allow :messages, [:index, :create]
      allow :meal_items, [:create, :update, :destroy]
      allow :line_items, [:create, :update, :destroy]
      allow :sessions, [:new, :create, :carts, :destroy]
      allow :users, [ :carts]
      allow_param :booking, [:walkin, :arrival, :pax, :customer_name, :contact, :notes, :booking_date, :state, :email]
      allow_param :meal, [:contact, :phone, :state, :start_time, :notes]
      allow_param :message, [:message, :message_type, :user_id, :create_time]
      allow_param :stock, [:item_id, :stock_date, :stock_level, :updated_at, :created_at]
    end
  end
end