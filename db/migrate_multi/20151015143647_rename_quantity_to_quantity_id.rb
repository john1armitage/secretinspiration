class RenameQuantityToQuantityId < ActiveRecord::Migration
  def change
    rename_column :ingredients, :quantity, :quantity_id
  end
end
