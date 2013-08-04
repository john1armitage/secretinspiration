class UpgradeMoneyFieldsPublic < ActiveRecord::Migration
  def change

    add_money :variants, :price, currency: { present: false }

    add_money :line_items, :net_item, currency: { present: false }

    add_money :line_items, :tax_item, currency: { present: false }

    add_money :line_items, :local_net_item, currency: { present: true }
    add_money :line_items, :local_tax_item, currency: { present: false }

    add_column :line_items, :exchange_rate, :decimal, :precision => 10, :scale => 7

    add_column :line_items, :vat_rate, :decimal, :precision => 5, :scale => 2

    add_money :line_items, :net_total_item, currency: { present: false }
    add_money :line_items, :tax_total_item, currency: { present: false }

    add_column :line_items, :discount_per_cent, :decimal, :precision => 8, :scale => 2
    add_money :line_items, :discount

  end
end
