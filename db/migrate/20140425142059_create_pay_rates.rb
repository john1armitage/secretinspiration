class CreatePayRates < ActiveRecord::Migration
  def change
    create_table :pay_rates do |t|
      t.belongs_to :employee, index: true
      t.date :effective_date
      t.money :rate

      t.timestamps
    end
  end
end
