class Daily < ActiveRecord::Base

  monetize :take_cents
  monetize :tips_cents
  monetize :credit_card_cents

  validates_presence_of :session, :account_date, :take, :credit_card, :tips
  validates_numericality_of :take, :credit_card, :tips
  before_save :get_totals

  def get_totals
    get_headcount
    #get_order_totals
  end

  def get_headcount
    self.headcount = Timesheet.where('work_date = ? AND session = ?', account_date, session).size
  end

  def get_order_totals
    order - Order.where('effective_date = ? AND session = ?', account_date, session)
    self.headcount = Timesheet.where('work_date = ? AND session = ?', account_date, session).size
  end

end
