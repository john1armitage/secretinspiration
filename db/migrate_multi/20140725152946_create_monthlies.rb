class CreateMonthlies < ActiveRecord::Migration
  def change
    create_table :monthlies do |t|
      t.integer :year
      t.integer :month
      t.money :takings, currency: { present: false }
      t.money :credit_card, currency: { present: false }
      t.money :cash, currency: { present: false }
      t.money :tax, currency: { present: false }
      t.money :turnover, currency: { present: false }
      t.money :cash_used, currency: { present: false }

      t.timestamps
    end
  end
end
