class AddDescToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :desc, :string
  end
end
