class AddVatRateToItems < ActiveRecord::Migration
  def change
    add_column :items, :vat_rate, :string
  end
end
