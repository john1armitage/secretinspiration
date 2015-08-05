class AddStatementToBanks < ActiveRecord::Migration
  def change
    add_column :banks, :statement, :boolean
  end
end
