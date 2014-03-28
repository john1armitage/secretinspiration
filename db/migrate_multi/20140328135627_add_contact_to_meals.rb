class AddContactToMeals < ActiveRecord::Migration
  def change
    add_column :meals, :contact, :string
    add_column :meals, :phone, :string
    add_column :meals, :notes, :text
  end
end
