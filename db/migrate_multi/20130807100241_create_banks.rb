class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
      t.string :name
      t.string :sort_code
      t.string :account_no
      t.money :opening_balance, currency: { present: true }
      t.text :notes

      t.timestamps
    end
  end
end
