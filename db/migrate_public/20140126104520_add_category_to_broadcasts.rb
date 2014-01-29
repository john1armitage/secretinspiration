class AddCategoryToBroadcasts < ActiveRecord::Migration
  def change
    add_column :broadcasts, :category, :string
    add_column :broadcasts, :blog, :boolean
  end
end
