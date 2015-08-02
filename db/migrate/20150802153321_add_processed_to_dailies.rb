class AddProcessedToDailies < ActiveRecord::Migration
  def change
    add_column :dailies, :processed, :boolean
  end
end
