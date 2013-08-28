class Allocation < ActiveRecord::Base

  monetize :amount
  belongs_to :payments
  belongs_to :orders

end
