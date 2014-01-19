class AddWithdrawnToItems < ActiveRecord::Migration
  def change
    add_column :items, :withdrawn, :boolean
  end
end
