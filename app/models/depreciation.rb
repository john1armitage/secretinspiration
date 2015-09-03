class Depreciation < ActiveRecord::Base


  def allowable_cost
    allowable_cost_cents / 100.00 if allowable_cost_cents
  end
  def allowable_cost=(val)
    self.allowable_cost_cents = val ? val.to_d * 100 : 0
  end

  belongs_to :financial

  default_scope { order('service_date ASC') }

  def summary
    financial.summary
  end

end
