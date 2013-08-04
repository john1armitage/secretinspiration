class AddVatRateToOptions < ActiveRecord::Migration
  def change
    remove_column :options, :vat_rate
    add_column :options, :vat_rate, :string
  end
end
