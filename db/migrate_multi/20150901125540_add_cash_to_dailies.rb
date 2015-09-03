class AddCashToDailies < ActiveRecord::Migration
  def change
    add_column :dailies, :cash_cents, :integer, default: 0
  end
end
