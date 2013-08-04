class AddAncestryDepthToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :ancestry_depth, :integer, :default => 0
  end
end
