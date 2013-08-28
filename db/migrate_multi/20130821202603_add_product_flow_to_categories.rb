class AddProductFlowToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :product_flow, :string
  end
end
