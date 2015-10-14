class AddStockerToItems < ActiveRecord::Migration
  def change
    add_column :items, :collapse, :boolean
    add_column :items, :stock_base_id, :integer
    add_column :items, :stock_base_part, :integer, default: 1
  end
end
