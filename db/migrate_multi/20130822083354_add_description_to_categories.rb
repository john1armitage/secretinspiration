class AddDescriptionToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :description, :string
    add_column :categories, :notes, :string
  end
end
