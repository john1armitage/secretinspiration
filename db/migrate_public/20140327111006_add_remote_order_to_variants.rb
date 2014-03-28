class AddRemoteOrderToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :remote_order, :boolean, default: true
  end
end
