class CreateDepreciations < ActiveRecord::Migration
  def change
    create_table :depreciations do |t|
      t.date :service_date, index: true
      t.belongs_to :order, index: true
      t.money :allowable_cost, currency: { present: false }
      t.integer :life_years, default: 3
    end
  end
end
