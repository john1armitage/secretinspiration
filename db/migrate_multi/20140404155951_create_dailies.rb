class CreateDailies < ActiveRecord::Migration
  def change
    create_table :dailies do |t|
      t.date :account_date
      t.decimal :turnover
      t.decimal :tips
      t.integer :headcount
      t.string :session

      t.timestamps
    end
  end
end
