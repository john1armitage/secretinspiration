class AddAccountToItemTypes < ActiveRecord::Migration
  def change
    add_reference :item_types, :account, index: true
  end
end
