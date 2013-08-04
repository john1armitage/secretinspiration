class ChangeChoicesToLineItems < ActiveRecord::Migration
    def change
      remove_column :line_items, :options
      add_column :line_items, :choices, :hstore
      add_column :line_items, :ancestry, :string
      add_column :line_items, :ancestry_depth, :integer, :default => 0
    end
end
