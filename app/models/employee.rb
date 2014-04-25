class Employee < ActiveRecord::Base

  monetize :hourly_rate_cents
  has_many :timesheets
  has_many :pay_rates

  def name
    first_name + " " + last_name + " "
  end

  def full_name
    title + " " + first_name + " " + last_name + " "
  end

  def name=(val)
    names = val.split(" ")
    title == names[0] && first_name == names[1] && last_name = name[2]
  end
end
