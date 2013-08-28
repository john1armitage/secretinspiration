class AddHomeCurrencyToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :home_currency, :string
  end
end
