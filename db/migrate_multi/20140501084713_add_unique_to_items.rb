class AddUniqueToItems < ActiveRecord::Migration
  def change
    add_column :items, :unique, :boolean
  end
end
