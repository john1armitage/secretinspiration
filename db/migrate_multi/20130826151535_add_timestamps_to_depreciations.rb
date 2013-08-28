class AddTimestampsToDepreciations < ActiveRecord::Migration
  def change
    add_timestamps :depreciations
  end
end
