module Permissions
  class ManagerPermission < BasePermission
    def initialize(user)
      allow :welcome, :index
      allow :bookings, [:index,:new, :create, :status, :dated, :edit, :update]
      allow :choices, [:index,:show]
      allow :pages, [:index, :blog,:show]
      allow :broadcasts, [:index, :blog,:show]
      allow :menus, [:sub,:show]
      allow :items, [:index, :update]
      allow :stocks, [:index, :destroy]
      allow :carts, [:index, :update, :clear]
      allow :meals, [:index, :takeaway, :create, :show, :clear, :patcher, :edit, :update, :form, :destroy, :check_out, :check_in]
      allow :messages, [:index, :create]
      allow :meal_items, [:new, :create, :update, :destroy]
      allow :orders, [:index, :show, :edit, :update, :create, :status]
      allow :line_items, [:create, :update, :destroy]
      allow :seatings, [:new, :create, :destroy]
      allow :sessions, [:new, :create, :carts, :destroy]
      allow :users, [ :carts]
      allow :dailies, [:index, :show, :new, :create, :edit, :update, :destroy]
      allow :timesheets, [:index, :new, :create, :edit, :update, :destroy]
      allow_param :booking, [:walkin, :arrival, :pax, :customer_name, :contact, :notes, :booking_date, :state, :email, :window, :confirmed]
      allow_param :meal, [:contact, :phone, :state, :start_time, :notes]
      allow_param :message, [:message, :message_type, :user_id, :create_time]
      allow_param :order, [:state, :net_total, :net_home, :tax_home, :paid, :credit_card, :tip, :voucher, :goods, :cheque, :cash, :net_total_cents, :net_home_cents, :tax_home_cents, :paid_cents, :credit_card_cents, :tip_cents, :voucher_cents, :goods_cents, :cheque_cents, :cash_cents ]
      allow_param :daily, [:headcount, :account_date, :credit_card, :session, :pax, :till, :surplus, :walkin_pax, :updated_at]
      allow_param :timesheet, [:employee_id, :start_time, :end_time, :hours, :work_date, :session, :pay, :pay_cents, :headcount]
      allow_param :stock, [:item_id, :stock_date, :stock_level, :updated_at, :created_at]
    end
  end
end