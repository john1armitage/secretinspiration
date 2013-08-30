class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.date :receipt_date
      t.money :amount, currency: { present: true }
      t.belongs_to :bank, index: true
      t.string :exchange_rate
      t.money :home_amount, currency: { present: false }
      t.string :state
      t.string :receivable_type
      t.integer :receivable_id

      t.timestamps
    end
  end
end
