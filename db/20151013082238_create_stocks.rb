class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.date :stock_date
      t.integer :stock_level
      t.integer :item_id
      t.string :timestamps
    end
  end
end
