class AddQuickFieldToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :desc, :string
    add_column :orders, :account_id, :integer
    add_column :orders, :quick, :boolean
    add_index :orders, :account_id
  end
end
