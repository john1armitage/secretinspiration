class Receipt < ActiveRecord::Base

  monetize :amount_cents
  monetize :home_amount_cents

  belongs_to :bank
  has_many :apportions
end
