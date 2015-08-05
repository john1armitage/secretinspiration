class AddDailyIdtoFinancials < ActiveRecord::Migration
  def change
    add_reference :dailies, :financial, index: true
    add_reference :financials, :daily, index: true
  end
end
