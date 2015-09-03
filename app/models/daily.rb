class Daily < ActiveRecord::Base

  # monetize :take_cents
  # monetize :tips_cents
  # monetize :turnover_cents
  # monetize :tax_cents
  # monetize :discount_cents
  # monetize :credit_card_cents
  # monetize :cash_cents
  # monetize :seated_cents
  # monetize :takeaway_cents
  # monetize :safe_cents, :allow_nil => true
  # monetize :petty_cents, :allow_nil => true
  # monetize :bank_cents, :allow_nil => true
  # monetize :till_cents, :allow_nil => true
  # monetize :safe_cash_cents, :allow_nil => true
  # monetize :surplus_cents, :allow_nil => true
  # monetize :cheque_cents, :allow_nil => true
  # monetize :goods_cents, :allow_nil => true

  def take
    take_cents / 100.00 if take_cents
  end
  def take=(val)
    self.take_cents = val ? val.to_d * 100.00 : 0
  end

  def tips
    tips_cents / 100.00 if tips_cents
  end
  def tips=(val)
    self.tips_cents = val ? val.to_d * 100.00 : 0
  end

  def turnover
    turnover_cents / 100.00 if turnover_cents
  end
  def turnover=(val)
    self.turnover_cents = val ? val.to_d * 100.00 : 0
  end

  def tax
    tax_cents / 100.00 if tax_cents
  end
  def tax=(val)
    self.tax_cents = val ? val.to_d * 100.00 : 0
  end

  def discount
    discount_cents / 100.00 if discount_cents
  end
  def discount=(val)
    self.discount_cents = val ? val.to_d * 100.00 : 0
  end

  def credit_card
    credit_card_cents / 100.00 if credit_card_cents
  end
  def credit_card=(val)
    self.credit_card_cents = val ? val.to_d * 100.00 : 0
  end

  def cash
    cash_cents / 100.00 if cash_cents
  end
  def cash=(val)
    self.cash_cents = val ? val.to_d * 100.00 : 0
  end

  def seated
    seated_cents / 100.00 if seated_cents
  end
  def seated=(val)
    self.seated_cents = val ? val.to_d * 100.00 : 0
  end

  def takeaway
    takeaway_cents / 100.00 if takeaway_cents
  end
  def takeaway=(val)
    self.takeaway_cents = val ? val.to_d * 100.00 : 0
  end

  def safe
    safe_cents / 100.00 if safe_cents
  end
  def safe=(val)
    self.safe_cents = val ? val.to_d * 100.00 : 0
  end

  def petty
    petty_cents / 100.00 if petty_cents
  end
  def petty=(val)
    self.petty_cents = val ? val.to_d * 100.00 : 0
  end

  def bank
    bank_cents / 100.00 if bank_cents
  end
  def bank=(val)
    self.bank_cents = val ? val.to_d * 100 : 0
  end

  def till
    till_cents / 100.00 if till_cents
  end
  def till=(val)
    self.till_cents = val ? val.to_d * 100.00 : 0
  end

  def safe_cash
    safe_cash_cents / 100.00 if safe_cash_cents
  end
  def safe_cash=(val)
    self.safe_cash_cents = val ? val.to_d * 100.00 : 0
  end

  def surplus
    surplus_cents / 100.00 if surplus_cents
  end
  def surplus=(val)
    self.surplus_cents = val ? val.to_d * 100.00 : 0
  end

  def cheque
    cheque_cents / 100.00 if cheque_cents
  end
  def cheque=(val)
    self.cheque_cents = val ? val.to_d * 100.00 : 0
  end

  def goods
    goods_cents / 100.00 if goods_cents
  end
  def goods=(val)
    self.goods_cents = val ? val.to_d * 100.00 : 0
  end

  has_many  :posts, as: :postable, dependent: :destroy

  validates_presence_of :session, :account_date, :take, :credit_card, :tips
  validates_numericality_of :take, :credit_card, :tips
  before_validation :get_totals

  before_save :get_HMRC_dates

  def get_HMRC_dates
    self.fin_year = account_date.year
    self.fin_year -= 1 unless account_date >= "06-04-#{fin_year}".to_date
    fin_year_start = "06-04-#{self.fin_year}".to_date
    self.week_no = (((account_date - fin_year_start)/7).to_i + 1)
  end

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
      cheque = orders.sum(&:cheque_cents)
      goods =  orders.sum(&:goods_cents)
      tips = orders.sum(&:tip_cents)
      take = orders.sum(&:paid_cents)
      self.goods_cents = goods
      self.cheque_cents = cheque
      self.tips_cents = tips
      self.take_cents = take
      # cheque sales credited on cheque credit
      received = take - (cheque + goods + tips)
      turnover =  (received / (1 + CONFIG[:vat_rate_standard])).to_i
      self.turnover_cents = turnover
      self.tax_cents = received - turnover
      self.discount_cents = orders.sum(&:discount_cents) + orders.sum(&:voucher_cents)
      self.takeaways = takeaways.size
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
      self.cheque_cents = 0
      self.goods_cents = 0
      self.takeaway_cents = 0
      self.seated_cents = 0
    end
  end

end

