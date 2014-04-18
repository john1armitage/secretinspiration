class AddSupplierIdToTenancies < ActiveRecord::Migration
  def change
    add_reference :tenancies, :supplier, index: true
  end
end
