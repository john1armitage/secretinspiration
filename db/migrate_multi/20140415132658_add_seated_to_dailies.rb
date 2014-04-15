class AddSeatedToDailies < ActiveRecord::Migration
  def change
    remove_column :dailies, :walkin_cents, :integer
    remove_column :dailies, :takeaway_cents, :integer
    remove_column :dailies, :booked_cents, :integer
    add_money :dailies, :seated, currency: { present: false }
    add_money :dailies, :takeaway, currency: { present: false }
    add_money :dailies, :discount, currency: { present: false }
    add_money :dailies, :turnover, currency: { present: false }
  end
end
