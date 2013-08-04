class LineItem < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :order_id
      t.integer :variant_id
      t.decimal :net_item, precision: 8, scale: 2
      t.decimal :tax_item, precision: 8, scale: 2
      t.integer :quantity
      t.hstore :options
      t.string :state

      t.text :notes

      t.timestamps
    end
  end
end
