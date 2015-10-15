class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.string :name
      t.integer :supplier_id
      t.string :reference
      t.integer :quantity
      t.integer :unit_id
      t.boolean :live, default: true
      t.text :notes

      t.timestamps
    end
  end
end
