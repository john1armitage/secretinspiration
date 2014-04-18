class AddTaxToDailies < ActiveRecord::Migration
  def change
    add_money :dailies, :tax, currency: { present: false }
  end
end
