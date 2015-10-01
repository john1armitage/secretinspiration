class AddFlagsToFinancials < ActiveRecord::Migration
  def change
    add_column :financials, :annual, :boolean
    add_column :financials, :invoice, :boolean
  end
end
