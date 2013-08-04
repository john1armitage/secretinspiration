class AddOptionsToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :options, :string, array: true
    add_column :categories, :choices, :string, array: true
  end
end
