class ChangeStructureDepreciations < ActiveRecord::Migration
  def change
    remove_column :depreciations, :order_id
    add_column :depreciations, :financial_id, :integer
  end
end
