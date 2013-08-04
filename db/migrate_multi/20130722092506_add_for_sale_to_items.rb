class AddForSaleToItems < ActiveRecord::Migration
  def change
    add_column :items, :for_sale, :boolean
  end
end
