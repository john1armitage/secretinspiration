class RenameGroupinginAccounts < ActiveRecord::Migration
  def change
    rename_column :accounts, :grouping, :grouping_id
  end
end
