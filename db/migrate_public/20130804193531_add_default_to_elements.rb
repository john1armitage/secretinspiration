class AddDefaultToElements < ActiveRecord::Migration
  def change
    add_column :elements, :default_choice, :boolean
  end
end
