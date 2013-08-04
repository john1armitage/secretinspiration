class CreateVariantEvents < ActiveRecord::Migration
  def change
    create_table :variant_events do |t|
      t.belongs_to :variant
      t.string :state
      t.integer :user_id
      t.timestamps
    end
  end
end
