class Allocation < ActiveRecord::Base

  monetize :amount_cents
  belongs_to :payments
  belongs_to :orders

end
