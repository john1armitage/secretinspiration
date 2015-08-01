class AddBankToFinancials < ActiveRecord::Migration
  def change
    add_column :financials, :bank, :string
  end
end
