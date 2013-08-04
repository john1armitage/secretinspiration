class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.belongs_to :customer, index: true
      t.belongs_to :user, index: true
      t.time :arrival
      t.boolean :window
      t.string :state
      t.integer :pax
      t.text :notes

      t.timestamps
    end
  end
end
