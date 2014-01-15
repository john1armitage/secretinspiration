class AddOrderIdToReceipts < ActiveRecord::Migration
  def change
    add_reference :receipts, :order, index: true
  end
end
