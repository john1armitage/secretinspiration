class CreateSupplies < ActiveRecord::Migration
  def change
    create_table :supplies do |t|
      t.belongs_to :supplier, index: true
      t.belongs_to :item, index: true
    end
  end
end
