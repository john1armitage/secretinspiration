class PayRate < ActiveRecord::Base
  belongs_to :employee

  monetize :rate_cents

end
