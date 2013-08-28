class AddVatRateToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :vat_rate, :string
  end
end
