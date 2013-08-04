class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :name
      t.string :phone1
      t.string :phone1
      t.string :email
      t.text :notes

      t.timestamps
    end
    add_index :customers, :name
  end
end
