class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.date :account_date, index: true
      t.string :currency, default: 'GBP'
      t.decimal :exchange_rate, :precision => 10, :scale => 6
      t.integer :home_amount_cents
      t.integer :debit_amount_cents
      t.integer :credit_amount_cents
      t.string :postable_type
      t.integer :postable_id
      t.integer :grouping
      t.timestamps null: false
    end
    add_index :posts, [:postable_type, :postable_id]
  end
end
