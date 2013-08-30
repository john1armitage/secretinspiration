class AddDescToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :desc, :string
  end
end
