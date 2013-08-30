class AddDescToApportions < ActiveRecord::Migration
  def change
    add_column :apportions, :desc, :string
  end
end
