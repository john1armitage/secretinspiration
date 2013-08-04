class ChangeGroupingFor < ActiveRecord::Migration
  def change
    add_column :items, :grouping, :string
    remove_column :items, :grouping_id #, :string
  end
end
