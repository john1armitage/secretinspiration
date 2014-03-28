class AddRemoteOrderToItems < ActiveRecord::Migration
  def change
    add_column :items, :remote_order, :boolean, default: false
  end
end
