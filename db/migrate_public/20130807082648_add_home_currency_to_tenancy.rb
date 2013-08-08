class AddHomeCurrencyToTenancy < ActiveRecord::Migration
  def change
    add_column :tenancies, :home_currency, :string
  end
end
