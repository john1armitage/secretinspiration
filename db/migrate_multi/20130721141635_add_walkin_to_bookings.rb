class AddWalkinToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :walkin, :boolean
  end
end
