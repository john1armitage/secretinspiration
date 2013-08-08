class CreatePostings < ActiveRecord::Migration
  def change
    create_table :postings do |t|
      t.date :event_date, index: true
      t.string :currency, default: 'GBP'
      t.decimal :exchange_rate, :precision => 10, :scale => 6
      t.money :home_amount, currency: { present: false }
      t.money :debit_amount, currency: { present: false }
      t.money :credit_amount, currency: { present: false }
      t.string :postable_type, index: true
      t.integer :postable_id, index: true
    end
    add_index :postings, [:postable_type, :postable_id]
  end
end
