class AddOptionsToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :options, :hstore
    add_column :item_fields, :options, :boolean
  end
end
