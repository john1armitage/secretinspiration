class Employee < ActiveRecord::Base

  monetize :hourly_rate_cents
  has_many :timesheets, dependent: :destroy
  has_many :pay_rates, dependent: :destroy
  has_many :wages, dependent: :destroy
  before_update :make_reference

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

  def make_reference
    self.reference = first_name if reference.blank?
  end

end
