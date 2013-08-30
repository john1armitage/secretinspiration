class CreateApportions < ActiveRecord::Migration
  def change
    create_table :apportions do |t|
      t.belongs_to :receipt, index: true
      t.money :amount, currency: { present: true }
      t.belongs_to :account, index: true

      t.timestamps
    end
  end
end
