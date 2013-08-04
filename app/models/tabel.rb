class Tabel < ActiveRecord::Base


  has_many :seatings, :dependent => :destroy
  has_many :bookings, :through => :seatings
  has_many :meals

  validates_presence_of :variant
  validates :name, uniqueness: true, presence: true
  validates_numericality_of :capacity

end
