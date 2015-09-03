class Bank < ActiveRecord::Base

  # monetize :opening_balance_cents, :allow_nil => true

  def opening_balance
    opening_balance_cents / 100.00 if opening_balance_cents
  end
  def opening_balance=(val)
    self.opening_balance_cents = val ? val.to_d * 100.00 : 0
  end

  validates :name, uniqueness: true, presence: true

  has_many  :posts, as: :accountable, dependent: :nullify

  default_scope { order('rank ASC, name ASC') }

  has_many :payments, dependent: :nullify
  has_many :receipts, dependent: :nullify
  has_many :transfers, dependent: :nullify

end
