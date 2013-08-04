class AddWindowToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :window, :boolean
  end
end
