class AddOrderedAtToMeals < ActiveRecord::Migration
  def change
    add_column :meals, :ordered_at, :time
  end
end
