class AddNotesToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :notes, :string
  end
end
