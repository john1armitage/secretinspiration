class AddCostToItems < ActiveRecord::Migration
  def change
    add_column :items, :cost_cents, :integer
  end
end
