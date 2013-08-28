class AddAmountToTransfers < ActiveRecord::Migration
  def change
    add_money :transfers, :amount, currency: { present: true }
    add_column :transfers, :desc, :string
  end
end
