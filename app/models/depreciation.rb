class Depreciation < ActiveRecord::Base

  monetize :allowed_amount

  belongs_to :order

end
