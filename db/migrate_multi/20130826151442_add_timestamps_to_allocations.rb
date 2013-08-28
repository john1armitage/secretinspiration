class AddTimestampsToAllocations < ActiveRecord::Migration
  def change
    add_timestamps :allocations
  end
end
