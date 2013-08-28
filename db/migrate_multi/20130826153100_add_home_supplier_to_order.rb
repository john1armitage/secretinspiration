class AddHomeSupplierToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :home_supplier, :boolean
  end
end
