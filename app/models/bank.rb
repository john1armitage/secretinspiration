class Bank < ActiveRecord::Base

  monetize :opening_balance_cents, :allow_nil => true

  validates :name, uniqueness: true, presence: true

  has_many  :postings, as: :accountable, dependent: :nullify

  default_scope { order('rank ASC, name ASC') }

  has_many :payments, dependent: :nullify
  has_many :receipts, dependent: :nullify
  has_many :transfers, dependent: :nullify

end
