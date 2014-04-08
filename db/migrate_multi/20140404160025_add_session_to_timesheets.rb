class AddSessionToTimesheets < ActiveRecord::Migration
  def change
    add_column :timesheets, :session, :string
  end
end
