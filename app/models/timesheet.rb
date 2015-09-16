class Timesheet < ActiveRecord::Base

  # monetize :pay_cents

  def pay
    pay_cents / 100.00 if pay_cents
  end
  def pay=(val)
    self.pay_cents = val ? val.to_d * 100.00 : 0
  end

  belongs_to :employee

  validates_presence_of :employee_id, :work_date, :start_time, :end_time, :session
#  validates_presence_of :hours, message: 'Check Times'

  before_validation :calculate_pay

  after_save :adjust_daily_headcount

  after_destroy :reduce_daily_headcount

  def calculate_pay
    if ['bonus','holiday'].include? session
      self.hours = 0
    else
      self.hours = hours
      rate_cents = employee.pay_rates.where('effective_date <= ?', work_date).order('effective_date DESC').first.rate_cents
      self.pay_cents = rate_cents ? (hours * rate_cents) : 0
    end
  end

  def adjust_daily_headcount
    if work_date_changed?
      headcount = Timesheet.where('work_date = ? AND session = ?', work_date_was, session).size
      Daily.where('account_date = ? AND session = ?', work_date_was, session).update_all(headcount: headcount)
    end
    headcount = Timesheet.where('work_date = ? AND session = ?', work_date, session).size
    Daily.where('account_date = ? AND session = ?', work_date, session).update_all(headcount: headcount)
  end

  def reduce_daily_headcount
    headcount = Timesheet.where('work_date = ? AND session = ?', work_date_was, session).size
    Daily.where('account_date = ? AND session = ?', work_date_was, session).update_all(headcount: headcount)
  end

end
