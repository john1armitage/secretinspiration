class Allocation < ActiveRecord::Base

  # monetize :amount_cents

  def amount
    amount_cents / 100.00 if amount_cents
  end
  def amount=(val)
    self.amount_cents = val ? val.to_d * 100.00 : 0
  end

  belongs_to :payments
  belongs_to :orders

end
