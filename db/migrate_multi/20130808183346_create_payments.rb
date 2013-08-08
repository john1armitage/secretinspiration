class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.date :payment_date, index: true
      t.money :amount, currency: { present: true, default: 'GBP' }
      t.integer :bank_id, index: true
      t.decimal :exchange_rate, :precision => 10, :scale => 6
      t.money :home_amount, currency: { present: false }
    end
  end
end
