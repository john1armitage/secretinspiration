class AddStockToItems < ActiveRecord::Migration
  def change
    add_column :items, :stock_item, :boolean
    add_column :items, :stock_level, :integer
    add_column :items, :stock_date, :date
  end
end
