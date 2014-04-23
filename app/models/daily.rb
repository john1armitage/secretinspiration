class Daily < ActiveRecord::Base

  monetize :take_cents
  monetize :tips_cents
  monetize :turnover_cents
  monetize :tax_cents
  monetize :discount_cents
  monetize :credit_card_cents
  monetize :seated_cents
  monetize :takeaway_cents

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

    orders = Order.where('effective_date = ? AND session = ?', account_date, session)
    if orders.size > 0
      takeaways = orders.where('effective_date = ? AND session = ? AND seating_id IS NULL', account_date, session)
      orders = orders.to_a
      self.takeaways = takeaways.size
      self.turnover_cents = orders.sum(&:net_home_cents)
      self.tips_cents = orders.sum(&:tip_cents)
      self.tax_cents = orders.sum(&:tax_home_cents)
      self.take_cents = self.turnover_cents + self.tax_cents + self.tips_cents
      self.discount_cents = orders.sum(&:discount_cents)
      self.takeaway_cents = takeaways.to_a.sum(&:net_home_cents)
      self.seated_cents = self.turnover_cents - self.takeaway_cents
    end
  end

end


# add_column :dailies, :pax, :integer
# add_column :dailies, :booked_pax, :integer
# add_column :dailies, :walkin_pax, :integer
# add_column :dailies, :takeaways, :integer
# add_money :dailies, :booked, currency: { present: false }
# add_money :dailies, :walkin, currency: { present: false }
# add_money :dailies, :takeaway, currency: { present: false }
