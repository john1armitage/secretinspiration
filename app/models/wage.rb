class Wage < ActiveRecord::Base

  def rate
    rate_cents / 100.00 if rate_cents
  end
  def rate=(val)
    self.rate_cents = val ? val.to_d * 100 : 0
  end

  def gross
    gross_cents / 100.00 if gross_cents
  end
  def gross=(val)
    self.gross_cents = val ? val.to_d * 100 : 0
  end

  def ni_employee
    ni_employee_cents / 100.00  if ni_employee_cents
  end
  def ni_employee=(val)
    self.ni_employee_cents = val ? val.to_d * 100 : 0
  end

  def ni_employer
    ni_employer_cents / 100.00 if ni_employer_cents
  end
  def ni_employer=(val)
    self.ni_employer_cents = val ? val.to_d * 100 : 0
  end

  def paye
    paye_cents / 100.00 if paye_cents
  end
  def paye=(val)
    self.paye_cents = val ? val.to_d * 100 : 0
  end

  def tips
    tips_cents / 100.00 if tips_cents
  end
  def tips=(val)
    self.tips_cents = val ? val.to_d * 100 : 0
  end

  def price
    price_cents / 100.00 if price_cents
  end
  def price=(val)
    self.price_cents = val ? val.to_d * 100 : 0
  end

  def holiday
    holiday_cents / 100.00 if holiday_cents
  end
  def holiday=(val)
    self.holiday_cents = val ? val.to_d * 100 : 0
  end

  def bonus
    bonus_cents / 100.00 if bonus_cents
  end
  def bonus=(val)
    self.bonus_cents = val ? val.to_d * 100 : 0
  end



  belongs_to :employee

  has_many  :posts, as: :postable, dependent: :destroy

  after_create

  validates_presence_of :employee_id, :message => 'is required'

  default_scope { order(:fy, :week_no) }

  def name
    employee.first_name
  end

end
