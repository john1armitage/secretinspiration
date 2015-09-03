class Monthly < ActiveRecord::Base

  # monetize :takings_cents, :allow_nil => true
  # monetize :credit_card_cents, :allow_nil => true
  # monetize :cash_cents, :allow_nil => true
  # monetize :tips_cents, :allow_nil => true
  # monetize :tax_cents, :allow_nil => true
  # monetize :turnover_cents, :allow_nil => true
  # monetize :cash_used_cents, :allow_nil => true

  def takings
    takings_cents / 100.00 if takings_cents
  end
  def takings=(val)
    self.takings_cents =  val ? val.to_d * 100 : 0
  end

  def credit_card
    credit_card_cents / 100.00 if credit_card_cents
  end
  def credit_card=(val)
    credit_card_cents = val ? val.to_d * 100 : 0
  end

  def cash
    cash_cents / 100.00 if cash_cents
  end
  def cash=(val)
    cash_cents = val ? val.to_d * 100 : 0
  end

  def tips
    tips_cents / 100.00 if tips_cents
  end
  def tips=(val)
    tips_cents = val ? val.to_d * 100 : 0
  end

  def tax
    tax_cents / 100.00 if tax_cents
  end
  def tax=(val)
    tax_cents = val ? val.to_d * 100 : 0
  end

  def turnover
    turnover_cents / 100.00 if turnover_cents
  end
  def turnover=(val)
    turnover_cents = val ? val.to_d * 100 : 0
  end

  def cash_used
    cash_used_cents / 100.00 if  cash_used_cents
  end
  def cash_used=(val)
    cash_used_cents = val ? val.to_d * 100 : 0
  end



end
