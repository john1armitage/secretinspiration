class AddIPaddressToCarts < ActiveRecord::Migration
  def change
    add_column :carts, :IP, :string
  end
end
