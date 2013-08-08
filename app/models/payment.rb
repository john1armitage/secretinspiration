class Payment < ActiveRecord::Base

  monetize :amount, :home_amount

  has_many :allocations
  has_many :orders, through: :allocations

  has_many  :postings, as: :postable, dependent: :destroy

end
