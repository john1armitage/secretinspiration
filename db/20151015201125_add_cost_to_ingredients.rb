class AddCostToIngredients < ActiveRecord::Migration
  def change
    add_column :ingredients, :cost_cents, :integer
  end
end
