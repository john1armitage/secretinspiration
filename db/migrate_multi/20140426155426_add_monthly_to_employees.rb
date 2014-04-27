class AddMonthlyToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :monthly, :boolean
  end
end
