class AddHomeSupplierToTenancies < ActiveRecord::Migration
  def change
    add_column :tenancies, :home_supplier, :string
  end
end
