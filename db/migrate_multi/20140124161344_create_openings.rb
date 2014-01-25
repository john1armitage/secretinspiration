class CreateOpenings < ActiveRecord::Migration
  def change
    create_table :openings do |t|
      t.date :start_date
      t.date :end_date
      t.integer :repeat
      t.string :frequency
      t.string :status
      t.string :message

      t.timestamps
    end
  end
end
