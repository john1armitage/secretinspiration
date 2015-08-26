class AddAllocatabilityToFinancials < ActiveRecord::Migration
  def change
    add_column :financials, :VAT, :money
    add_column :financials, :account_id, :integer
  end
end
