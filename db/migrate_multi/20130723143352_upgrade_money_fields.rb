class UpgradeMoneyFields < ActiveRecord::Migration
  def change

    #remove_field :items, :price
    add_money :items, :price, currency: { present: false }

    add_money :orders, :net_total, currency: { present: false }
    #remove_field :orders, :net_total

    add_money :orders, :tax_total, currency: { present: false }
    #remove_field :orders, :tax_total

    add_money :orders, :adjustment_total, currency: { present: false }
    #remove_field :orders, :adjustment_total

    add_column :orders, :discount_per_cent, :decimal, :precision => 8, :scale => 2
    add_money :orders, :discount

    #remove_field :suppliers, :opening_balance
    add_money :suppliers, :opening_balance, currency: { present: false }

    #remove_field :accounts, :opening_balance
    add_money :accounts, :opening_balance, currency: { present: false }
  end
end
