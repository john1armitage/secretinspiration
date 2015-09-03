class ChangeTaxHomeInFinancials < ActiveRecord::Migration
  def change
    remove_column :financials, :tax_home_cents
    add_column :financials, :tax_home_cents, :integer, default: 0
  end
end
