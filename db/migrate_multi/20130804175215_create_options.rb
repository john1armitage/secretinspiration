class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
      t.string :name
      t.money :price, currency: { present: false }
      t.decimal :vat_rate, :precision => 5, :scale => 2

      t.timestamps
    end
    add_index :options, :name
  end
end
