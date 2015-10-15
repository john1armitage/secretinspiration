class AddOrderingtoSupplier < ActiveRecord::Migration
  def change
    add_column :suppliers, :ordering, :boolean, default: false
  end
end
