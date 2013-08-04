class AddAncestryDepthToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :ancestry_depth, :integer, :default => 0
  end
end
