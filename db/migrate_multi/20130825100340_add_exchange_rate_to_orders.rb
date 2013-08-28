class AddExchangeRateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :exchange_rate, :decimal, :precision => 10, :scale => 7
  end
end
