module Permissions
  class ManagerPermission < BasePermission
    def initialize(user)
      allow :welcome, :index
      allow :bookings, [:index,:new, :create, :status, :dated, :edit, :update]
      allow :choices, [:index,:xshow]
      allow :pages, [:index, :blog,:xshow]
      allow :broadcasts, [:index, :blog,:xshow]
      allow :menus, [:sub,:xshow]
      allow :carts, [:index, :update, :clear]
      allow :meals, [:index, :takeaway, :create, :xshow, :clear, :patcher, :edit, :update, :form, :destroy, :check_out, :check_in]
      allow :messages, [:index, :create]
      allow :meal_items, [:new, :create, :update, :destroy]
      allow :orders, [:index, :xshow, :edit, :update, :create, :status]
      allow :line_items, [:create, :update, :destroy]
      allow :seatings, [:new, :create, :destroy]
      allow :sessions, [:new, :create, :carts, :destroy]
      allow :users, [ :carts]
      allow :dailies, [:index, :xshow, :new, :create, :edit, :update, :destroy]
      allow :timesheets, [:index, :new, :create, :edit, :update, :destroy]
      allow_param :booking, [:walkin, :arrival, :pax, :customer_name, :contact, :notes, :booking_date, :state, :email, :window, :confirmed]
      allow_param :meal, [:contact, :phone, :state, :start_time, :notes]
      allow_param :message, [:message, :message_type, :user_id, :create_time]
      allow_param :order, [:state, :paid, :credit_card, :tip]
      allow_param :daily, [:headcount, :account_date, :credit_card, :session, :pax, :till, :surplus, :walkin_pax, :updated_at]
      allow_param :timesheet, [:employee_id, :start_time, :end_time, :hours, :work_date, :session, :rate_cents, :headcount]
      #allow :choices, :index
      #allow :users, [:new, :carts, :form, :update]
      #allow :sessions, [:new, :carts, :destroy]
      #allow :items_exists, [:index, :xshow, :new, :carts, :form, :update]
      #allow :welcome, :index
      #allow :bookings, [:index,:new, :create]
      #allow :choices, [:index,:xshow]
      #allow :pages, [:index, :blog,:xshow]
      #allow :broadcasts, [:index, :blog,:xshow]
      #allow :menus, [:sub,:xshow]
      #allow :carts, [:index, :update, :clear]
      #allow :meals, [:takeaway, :xshow, :clear, :patcher]
      #allow :meal_items, [:create, :update, :destroy]
      #allow :line_items, [:create, :update, :destroy]
      #allow :sessions, [:new, :create, :carts, :destroy]
      #allow :users, [ :carts]
      #allow_param :booking, [:walkin, :arrival, :pax, :customer_name, :contact, :notes, :booking_date, :state, :email]
      #allow_param :meal, [:contact, :phone, :state, :start_time, :notes]
    end
  end
end