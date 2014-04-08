class Daily < ActiveRecord::Base

  validates_presence_of :session, :account_date, :turnover, :tips
  validates_numericality_of :turnover, :tips
  before_save :get_headcount

  def get_headcount
    self.headcount = Timesheet.where('work_date = ? AND session = ?', account_date, session).size
  end

end
