class AddLiveToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :live, :boolean, default: true
  end
end
