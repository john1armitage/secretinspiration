class AddEffectiveDateToFinancials < ActiveRecord::Migration
  def change
    add_column :financials, :effective_date, :date
    add_column :financials, :depreciation, :boolean
  end
end
