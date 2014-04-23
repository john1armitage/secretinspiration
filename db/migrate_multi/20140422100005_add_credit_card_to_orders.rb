class AddCreditCardToOrders < ActiveRecord::Migration
  def change
    add_money :orders, :credit_card, currency: { present: false }
  end
end
