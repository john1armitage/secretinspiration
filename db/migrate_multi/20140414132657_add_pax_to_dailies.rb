class AddPaxToDailies < ActiveRecord::Migration
  def change
    add_column :dailies, :pax, :integer
    add_column :dailies, :booked_pax, :integer
    add_column :dailies, :walkin_pax, :integer
    add_column :dailies, :takeaways, :integer
    add_money :dailies, :booked, currency: { present: false }
    add_money :dailies, :walkin, currency: { present: false }
    add_money :dailies, :takeaway, currency: { present: false }
  end
end
