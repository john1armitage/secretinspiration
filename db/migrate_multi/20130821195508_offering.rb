class Offering < ActiveRecord::Migration
  def change
    create_table :offerings do |t|
      t.belongs_to :supplier, index: true
      t.belongs_to :category, index: true
    end
  end
end
