class AddChequeToDailies < ActiveRecord::Migration
  def change
    add_column :dailies, :goods_cents, :integer, default: 0
    add_column :dailies, :cheque_cents, :integer, default: 0
  end
end
