class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.date :transfer_date
      t.belongs_to :bank, index: true
      t.belongs_to :recipient, index: true
      t.decimal :exchange_rate

      t.timestamps
    end
  end
end
