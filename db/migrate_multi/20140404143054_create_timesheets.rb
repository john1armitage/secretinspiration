class CreateTimesheets < ActiveRecord::Migration
  def change
    create_table :timesheets do |t|
      t.belongs_to :employee
      t.decimal :hours
      t.date :work_date
      t.time :start_time
      t.time :end_time

      t.timestamps
    end
  end
end
