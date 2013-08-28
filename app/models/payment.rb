class Payment < ActiveRecord::Base

  include AccountPosting

  monetize :amount, :home_amount

  has_many :allocations, dependent: :destroy
  has_many :orders, through: :allocations

  has_many  :postings, as: :postable, dependent: :destroy

  belongs_to :payable, polymorphic: true

  belongs_to :account

end
