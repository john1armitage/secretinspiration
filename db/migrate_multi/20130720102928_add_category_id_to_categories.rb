class AddCategoryIdToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :root_id, :integer
    add_column :categories, :category_id, :integer
    add_index :categories, :category_id
  end
end
