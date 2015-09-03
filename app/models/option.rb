class Option < ActiveRecord::Base

  # monetize :price_cents, :allow_nil => true

  def price
    price_cents / 100.00 if price_cents
  end
  def price=(val)
    self.price_cents = val ? val.to_d * 100 : 0
  end

  has_many :line_items

end
