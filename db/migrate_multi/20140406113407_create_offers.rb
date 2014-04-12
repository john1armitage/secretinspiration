class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.string :days, array: true
      t.string :offer_type
      t.belongs_to :category
      t.decimal :amount
      t.string :name
      t.string :short
      t.text :desc
      t.text :notes
      t.boolean :live, default: true

      t.timestamps
    end
  end
end
