class AddAccountableToPostings < ActiveRecord::Migration
  def change
    add_column :postings, :accountable_type, :string
    add_column :postings, :accountable_id, :integer
    remove_column :postings, :home_amount_cents
    remove_column :postings, :currency
    remove_column :postings, :exchange_rate
  end
end
