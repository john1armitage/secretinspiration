class AddSpecialToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :special, :string
  end
end
