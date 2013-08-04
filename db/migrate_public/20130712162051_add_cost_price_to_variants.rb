class AddCostPriceToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :cost_price, :decimal, precision: 8, scale: 2
  end
end
