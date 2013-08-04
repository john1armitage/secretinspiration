class ChangeItemFields < ActiveRecord::Migration
  def change
    add_column :item_fields, :rank, :integer
    remove_column :item_fields, :required
    remove_column :item_fields, :item_type_id
  end
end
