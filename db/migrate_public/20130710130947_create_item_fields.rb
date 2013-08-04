class CreateItemFields < ActiveRecord::Migration
  def change
    create_table :item_fields do |t|
      t.string :name
      t.string :field_type
      t.boolean :required
      t.string :item_type

      t.timestamps
    end
  end
end
