class CreateTableTimings < ActiveRecord::Migration
  def change
    create_table :timings do |t|
      t.string :state
      t.string :timeable_type
      t.integer :timeable_id
      t.timestamps
    end
  end
end
