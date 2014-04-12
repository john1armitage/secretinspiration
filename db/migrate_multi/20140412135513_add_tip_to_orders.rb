class AddTipToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :tip_cents, :integer
  end
end
