class CreateSeatings < ActiveRecord::Migration
  def change
    create_table :seatings do |t|
      t.belongs_to :tabel, index: true
      t.belongs_to :booking, index: true

      t.timestamps
    end
  end
end
