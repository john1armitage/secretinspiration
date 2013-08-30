class AddDescToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :desc, :string
  end
end
