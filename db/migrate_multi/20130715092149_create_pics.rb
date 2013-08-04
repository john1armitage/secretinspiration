class CreatePics < ActiveRecord::Migration
  def change
    create_table :pics do |t|
      t.string   :name
      t.string  :image
      t.belongs_to :viewable, polymorphic: true

      t.timestamps
    end
    add_index :pics, [:viewable_id, :viewable_type]
  end
end
