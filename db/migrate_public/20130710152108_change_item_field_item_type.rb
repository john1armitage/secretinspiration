class ChangeItemFieldItemType < ActiveRecord::Migration
  def change
    remove_column :item_fields, :item_type
    add_column :item_fields, :item_type_id, :integer
  end
end
