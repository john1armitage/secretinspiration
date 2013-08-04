class ChangeOwnableForLineItems < ActiveRecord::Migration
  def change
    remove_column :line_items, :cart_id
    remove_column :line_items, :order_id
    add_column :line_items, :ownable_id, :integer
    add_column :line_items, :ownable_type, :string
  end
end
