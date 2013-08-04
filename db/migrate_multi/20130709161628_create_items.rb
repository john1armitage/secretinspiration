class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.text :desc
      t.decimal :price, precision: 8, scale: 2
      t.string :category
      t.boolean :mailable

      t.timestamps
    end
  end
end
