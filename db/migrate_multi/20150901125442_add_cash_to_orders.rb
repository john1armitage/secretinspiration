class AddCashToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :cash_cents, :integer, default: 0
  end
end
