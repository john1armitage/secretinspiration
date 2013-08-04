class CreateVariantStock < ActiveRecord::Migration
  def change
    create_table :variant_stocks do |t|
      t.integer :variant_id
      t.integer :stock
      t.string :domain
      t.hstore :options
    end
  end
end
