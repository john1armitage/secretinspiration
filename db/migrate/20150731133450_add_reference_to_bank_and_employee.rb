class AddReferenceToBankAndEmployee < ActiveRecord::Migration
  def change
    add_column :employees, :reference, :string
    add_column :banks, :reference, :string
  end
end
