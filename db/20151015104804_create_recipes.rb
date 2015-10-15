class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.integer :item_id
      t.integer :ingredient_id
      t.integer :amount_id

      t.timestamps
    end
  end
end
