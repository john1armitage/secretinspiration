class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.string :name
      t.string :phone1
      t.string :phone2
      t.string :email
      t.string :contact
      t.string :reference
      t.string :state
      t.string :category
      t.string :notes
      t.decimal :opening_balance, precision: 8, scale: 2

      t.timestamps
    end
    add_index :suppliers, :name
  end
end
