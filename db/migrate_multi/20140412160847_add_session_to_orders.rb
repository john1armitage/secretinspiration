class AddSessionToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :session, :string
  end
end
