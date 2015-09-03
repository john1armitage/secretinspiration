class PayRate < ActiveRecord::Base
  belongs_to :employee

  # monetize :rate_cents

  def rate
    rate_cents / 100.00 if rate_cent
  end
  def rate=(val)
    self.rate_cents = val ? val.to_d * 100 : 0
  end


end
