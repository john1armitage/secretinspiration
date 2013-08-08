class CreateAllocations < ActiveRecord::Migration
  def change
    create_table :allocations do |t|
      t.money :amount, currency: { present: false }
      t.belongs_to :payment, index: true
      t.belongs_to :order, index: true
    end
  end
end
