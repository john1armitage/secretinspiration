class CreateTabels < ActiveRecord::Migration
  def change
    create_table :tabels do |t|
      t.string :name
      t.string :variant
      t.integer :capacity

      t.timestamps
    end
    add_index :tabels, :name
  end
end
