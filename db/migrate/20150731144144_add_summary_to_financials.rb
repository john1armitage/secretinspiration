class AddSummaryToFinancials < ActiveRecord::Migration
  def change
    add_column :financials, :summary, :string
    add_column :financials, :entity_ref, :string
  end
end
