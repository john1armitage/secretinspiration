class Supplier < ActiveRecord::Base

  # monetize :opening_balance_cents, :allow_nil => true

  def opening_balance
    opening_balance_cents / 100.00 if opening_balance_cents
  end
  def opening_balance=(val)
    self.opening_balance_cents = val ? val.to_d * 100 : 0
  end

  validates :name, uniqueness: true, presence: true

  has_many :orders
  has_many :supplies
  has_many :items, through: :supplies
  has_many :offerings
  has_many :categories, through: :offerings
  has_many  :posts, as: :accountable, dependent: :nullify

  has_many  :payments, as: :payable, dependent: :destroy

  default_scope { order('rank, name ASC') }

  def cats
    offerings.map {|o| o.category_id}
  end


end
