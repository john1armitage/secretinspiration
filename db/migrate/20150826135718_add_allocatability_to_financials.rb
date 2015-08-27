class AddAllocatabilityToFinancials < ActiveRecord::Migration
  def change
    add_column :financials, :tax_home_cents, :integer
    add_column :financials, :account_id, :integer
  end
end
