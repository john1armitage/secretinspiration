class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.decimal :net_total, precision: 8, scale: 2
      t.decimal :tax_total, precision: 8, scale: 2
      t.decimal :adjustment_total, precision: 8, scale: 2
      t.date :effective_date
      t.date :due_date
      t.integer :user_id
      t.integer :customer_id
      t.integer :supplier_id
      t.string :state
      t.text :special_instructions
      t.text :notes

      t.timestamps
    end
  end
end
