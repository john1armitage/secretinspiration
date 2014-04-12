class ChangeCategoriesInOffers < ActiveRecord::Migration
  def change
    remove_column :offers, :category_id
    add_column :offers, :categories, :string, array: true
  end
end
