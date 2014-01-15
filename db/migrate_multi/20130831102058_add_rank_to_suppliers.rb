class AddRankToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :rank, :integer
  end
end
