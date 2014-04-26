class AddPayToTimesheets < ActiveRecord::Migration
  def change
    add_money :timesheets, :pay, currency: { present: false }
  end
end
