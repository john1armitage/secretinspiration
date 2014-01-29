class AddSeatingToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :seating_id, :integer
  end
end
