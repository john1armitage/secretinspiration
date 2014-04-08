class Employee < ActiveRecord::Base

  monetize :hourly_rate_cents
  has_many :timesheets

  def name
    title + " " + first_name + " " + last_name + " "
  end
end
