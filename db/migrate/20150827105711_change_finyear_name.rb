class ChangeFinyearName < ActiveRecord::Migration
  def change
    rename_column :dailies, :FY, :fin_year
    remove_column :dailies, :financial_id
  end
end
