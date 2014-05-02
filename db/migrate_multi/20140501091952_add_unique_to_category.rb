class AddUniqueToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :unique, :boolean
  end
end
