class AddProductFlowToItems < ActiveRecord::Migration
  def change
    remove_column :items, :for_sale
    add_column :items, :product_flow, :string
  end
end
