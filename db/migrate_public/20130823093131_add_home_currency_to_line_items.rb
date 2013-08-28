class AddHomeCurrencyToLineItems < ActiveRecord::Migration
  def change
    remove_column :line_items, :net_item_cents
    remove_column :line_items, :local_net_item_cents
    remove_column :line_items, :local_tax_item_cents
    remove_column :line_items, :local_net_item_currency
    add_money :line_items, :net_item, currency: { present: true }
    add_money :line_items, :net_home, currency: { present: false }
    add_money :line_items, :tax_home, currency: { present: false }
    remove_column :line_items, :discount_currency
    add_column :line_items, :contra, :boolean
  end
end
