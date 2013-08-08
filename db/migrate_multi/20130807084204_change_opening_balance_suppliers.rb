class ChangeOpeningBalanceSuppliers < ActiveRecord::Migration
  def change
    remove_column :suppliers, :opening_balance_cents
    add_money :suppliers, :opening_balance, currency: { present: true }
  end
end
