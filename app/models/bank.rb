class Bank < ActiveRecord::Base

  monetize :opening_balance_cents, :allow_nil => true

  validates :name, uniqueness: true, presence: true

end
