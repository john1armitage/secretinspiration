class AddSlugToBroadcasts < ActiveRecord::Migration
  def change
    add_column :broadcasts, :slug, :string
  end
end
