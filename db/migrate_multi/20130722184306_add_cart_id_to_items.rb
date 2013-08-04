class AddCartIdToItems < ActiveRecord::Migration
  def change
    add_column :line_items, :cart_id, :integer
    add_column :line_items, :account_id, :integer
  end
end
