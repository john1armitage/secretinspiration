class AddGroupingToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :grouping, :integer
  end
end
