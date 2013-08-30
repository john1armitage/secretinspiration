class AddPaidToOrders < ActiveRecord::Migration
  def change
    add_money :orders, :paid, currency: { present: false }
  end
end
