class Timesheet < ActiveRecord::Base

  belongs_to :employee

  validates_presence_of :employee_id, :work_date, :start_time, :end_time, :session
  validates_presence_of :hours, message: 'Check Times'

  before_validation :calculate_hours

  after_validation :adjust_daily_headcount

  def calculate_hours
    hours = (end_time - start_time) / 3600
    self.hours = hours <= 0 ? nil : hours
  end

  def adjust_daily_headcount
    headcount = Timesheet.where('work_date = ? AND session = ?', work_date, session).size
    if work_date != work_date_was
      Daily.where('account_date = ? AND session = ?', work_date_was, session).update_all(headcount: headcount)
    end
    Daily.where('account_date = ? AND session = ?', work_date, session).update_all(headcount: headcount)
  end


end
