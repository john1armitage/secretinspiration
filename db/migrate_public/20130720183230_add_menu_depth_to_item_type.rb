class AddMenuDepthToItemType < ActiveRecord::Migration
  def change
    add_column :item_types, :menu_depth, :integer
  end
end
