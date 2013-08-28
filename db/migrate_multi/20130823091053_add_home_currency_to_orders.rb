class AddHomeCurrencyToOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :net_total_cents
    add_money :orders, :net_total, currency: { present: true }
    add_money :orders, :net_home, currency: { present: false }
    add_money :orders, :tax_home, currency: { present: false }
    add_column :orders, :contra, :boolean
    remove_column :orders, :discount_currency
    remove_column :orders, :currency

  end

end

