class AddVoucherToOrders < ActiveRecord::Migration
  def change
    add_money :orders, :voucher, currency: { present: false }
  end
end
