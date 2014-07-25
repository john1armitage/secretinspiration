class Daily < ActiveRecord::Base

  monetize :take_cents
  monetize :tips_cents
  monetize :turnover_cents
  monetize :tax_cents
  monetize :discount_cents
  monetize :credit_card_cents
  monetize :seated_cents
  monetize :takeaway_cents
  monetize :safe_cents, :allow_nil => true
  monetize :petty_cents, :allow_nil => true
  monetize :bank_cents, :allow_nil => true
  monetize :till_cents, :allow_nil => true
  monetize :safe_cash_cents, :allow_nil => true
  monetize :surplus_cents, :allow_nil => true

  validates_presence_of :session, :account_date, :take, :credit_card, :tips
  validates_numericality_of :take, :credit_card, :tips
  before_validation :get_totals

  def get_totals
    get_headcount
    get_order_totals
  end

  def get_headcount
    self.headcount = Timesheet.where('work_date = ? AND session = ?', account_date, session).size
  end

  def get_order_totals

    bookings = Booking.where('booking_date = ? AND session = ?', account_date, session)
    if bookings.size > 0
      walkins = bookings.where('walkin = ?', true)
      self.pax = bookings.to_a.sum(&:pax)
      self.walkin_pax = walkins.to_a.sum(&:pax)
      self.booked_pax = self.pax - self.walkin_pax
    end

    orders = Order.where('effective_date = ? AND session = ? AND state = ?', account_date, session, 'complete')
    if orders.size > 0
      takeaways = orders.where('seating_id IS NULL')
      orders = orders.to_a
      self.takeaways = takeaways.size
      self.turnover_cents = orders.sum(&:net_home_cents)
      self.tips_cents = orders.sum(&:tip_cents)
      self.tax_cents = orders.sum(&:tax_home_cents)
      self.take_cents = self.turnover_cents + self.tax_cents + self.tips_cents
      self.discount_cents = orders.sum(&:discount_cents)
      self.takeaway_cents = takeaways.to_a.sum(&:net_home_cents)
      self.seated_cents = self.turnover_cents - self.takeaway_cents
    elsif take_cents.to_d > 0
      self.turnover_cents = ((take_cents.to_d - tips_cents.to_d) / (1 + CONFIG[:vat_rate_standard]).to_d).ceil
      self.tax_cents = take_cents - ( turnover_cents + tips_cents.to_d)
    else
      self.takeaways = 0
      self.turnover_cents = 0
      self.tips_cents = 0
      self.tax_cents = 0
      self.take_cents = 0
      self.discount_cents = 0
      self.takeaway_cents = 0
      self.seated_cents = 0
    end
  end

end

