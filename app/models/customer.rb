class Customer < ActiveRecord::Base

  validates :name, uniqueness: true, presence: true

  has_many :orders

  has_many  :payments, as: :payable, dependent: :destroy

end
