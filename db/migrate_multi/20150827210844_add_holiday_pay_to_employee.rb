class AddHolidayPayToEmployee < ActiveRecord::Migration
  def change
    add_column :employees, :holiday, :boolean
  end
end
