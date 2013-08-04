class AddRootParentFieldsToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :root_id, :integer
    add_column :accounts, :account_id, :integer
  end
end
