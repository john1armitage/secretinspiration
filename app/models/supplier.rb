class Supplier < ActiveRecord::Base

  monetize :opening_balance_cents, :allow_nil => true

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
