class AddRepeatToEvent < ActiveRecord::Migration
  def change
    add_column :broadcasts, :repeat, :integer
    add_column :broadcasts, :frequency, :string
  end
end
