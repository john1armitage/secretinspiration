class AddSafeCashToDailies < ActiveRecord::Migration
  def change
    add_money :dailies, :safe_cash, currency: { present: false }
    add_column :dailies, :safe_reason, :string
  end
end
