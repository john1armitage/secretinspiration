class AddPholourieToMeals < ActiveRecord::Migration
  def change
    add_column :meals, :pholourie, :boolean
  end
end
