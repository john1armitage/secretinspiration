class AddChoicesToItems < ActiveRecord::Migration
  def change
    add_column :items, :choices, :string, array: true
  end
end
