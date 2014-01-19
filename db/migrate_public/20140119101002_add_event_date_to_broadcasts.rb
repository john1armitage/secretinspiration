class AddEventDateToBroadcasts < ActiveRecord::Migration
  def change
    add_column :broadcasts, :event_date, :date
    add_column :broadcasts, :event_time, :time
  end
end
