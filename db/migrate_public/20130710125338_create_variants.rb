class CreateVariants < ActiveRecord::Migration
  def change
    create_table :variants do |t|
      t.integer :item_id
      t.string :domain
      t.string :name
      t.text :desc
      t.decimal :price, precision: 8, scale: 2
      t.boolean :item_default
      t.integer :stock
      t.date :available_on
      t.hstore :properties

      t.timestamps
    end
  end
  def up
    execute 'CREATE INDEX variants_properties ON variants USING gin(properties)'
  end

  def down
    execute 'DROP INDEX variants_properties'
  end

end
