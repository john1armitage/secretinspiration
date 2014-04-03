class AddOptionsToItems < ActiveRecord::Migration
  def change
    add_column :items, :options, :string, array: true
  end
end
