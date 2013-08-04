class CreateElements < ActiveRecord::Migration
  def change
    create_table :elements do |t|
      t.string :name
      t.string :kind
      t.string :desc
      t.integer :rank

      t.timestamps
    end
  end
end
