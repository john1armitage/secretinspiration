class AddCashToDailies < ActiveRecord::Migration
  def change
    add_money :dailies, :safe, currency: { present: false }
    add_money :dailies, :petty, currency: { present: false }
    add_money :dailies, :bank, currency: { present: false }
  end
end
