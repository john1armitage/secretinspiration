class Timesheet < ActiveRecord::Base

  belongs_to :employee

  validates_presence_of :employee_id, :work_date, :start_time, :end_time, :session
  validates_presence_of :hours, message: 'Check Times'

  before_validation :calculate_hours

  def calculate_hours
    hours = (end_time - start_time) / 3600
    self.hours = hours <= 0 ? nil : hours
  end


end
