class AddStateToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :state, :string, default: 'incomplete'
  end
end
