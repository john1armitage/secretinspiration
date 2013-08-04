class AddGroupingToItems < ActiveRecord::Migration
  def change
    add_column :items, :grouping_id, :integer
    add_index :items, :grouping_id
  end
end
