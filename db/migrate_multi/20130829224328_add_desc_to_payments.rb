class AddDescToPayments < ActiveRecord::Migration
  def changeDe
    add_column :payments, :desc, :string
  end
end
