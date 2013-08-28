class AddIncomingToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :incoming, :boolean
  end
end
