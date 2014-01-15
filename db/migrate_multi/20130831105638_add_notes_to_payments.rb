class AddNotesToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :notes, :string
  end
end
