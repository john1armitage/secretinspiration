class AddOptionIdToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :option_id, :integer
    add_column :line_items, :options, :string
  end
end
