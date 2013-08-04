class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :code
      t.string :ancestry
      t.decimal :opening_balance, precision: 8, scale: 2

      t.timestamps
    end
    add_index :accounts, :name
    add_index :accounts, :code
    add_index :accounts, :ancestry
  end
end
