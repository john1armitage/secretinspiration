class CreateItemTypes < ActiveRecord::Migration
  def change
    create_table :item_types do |t|
      t.string :name
      t.integer :rank
      t.hstore :properties

      t.timestamps
    end
  end
end
