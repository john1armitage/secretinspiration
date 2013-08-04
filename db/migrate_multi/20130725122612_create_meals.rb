class CreateMeals < ActiveRecord::Migration
  def change
    create_table :meals do |t|
      t.belongs_to  :seating, index: true
      t.string      :tabel_name
      t.time        :start_time
      t.string      :state
      t.timestamps
    end
    add_index :meals, :tabel_name
    add_index :meals, :start_time
    add_index :meals, :state
  end
end
