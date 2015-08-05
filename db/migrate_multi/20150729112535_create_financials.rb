class CreateFinancials < ActiveRecord::Migration
  def change
    create_table :financials do |t|
      t.date :event_date
      t.boolean :credit, default: false
      t.string :classification
      t.string :entity
      t.integer :entity_id
      t.integer :mandate
      t.string :desc
      t.integer :credit_amount_cents
      t.string :credit_amount_currency, default: 'GBP'
      t.integer :debit_amount_cents
      t.string :debit_amount_currency, default: 'GBP'
      t.boolean :resolved, default: false
      t.boolean :processed, default: false
      t.timestamps null: false
    end
  end
end
