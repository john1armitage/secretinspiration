class AddIpToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :IP, :string
  end
end
