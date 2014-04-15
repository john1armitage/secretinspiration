class AddSessionToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :session, :string
  end
end
