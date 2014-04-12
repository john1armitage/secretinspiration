class CreateDailies < ActiveRecord::Migration
  def change
    create_table :dailies do |t|
      t.date :account_date
      t.money :take, currency: { present: true, default: 'GBP' }
      t.money :tips, currency: { present: true, default: 'GBP' }
      t.money :credit_card, currency: { present: true, default: 'GBP' }
      t.integer :headcount
      t.string :session

      t.timestamps
    end
  end
end
