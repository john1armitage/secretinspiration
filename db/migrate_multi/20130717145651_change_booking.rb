class ChangeBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :customer_name, :string
    add_column :bookings, :contact, :string
    add_column :bookings, :booking_date, :date
    add_index :bookings, :customer_name
    add_index :bookings, [:booking_date, :arrival]
  end
end
