class AddStateToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :state, :string, default: 'incomplete'
  end
end
