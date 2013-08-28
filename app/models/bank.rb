class Bank < ActiveRecord::Base

  monetize :opening_balance_cents, :allow_nil => true

  validates :name, uniqueness: true, presence: true

  has_many  :postings, as: :accountable, dependent: :nullify

  default_scope { order('rank ASC, name ASC') }


end
