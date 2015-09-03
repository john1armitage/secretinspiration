class AddChequeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :goods_cents, :integer, default: 0
    add_column :orders, :cheque_cents, :integer, default: 0
  end
end
