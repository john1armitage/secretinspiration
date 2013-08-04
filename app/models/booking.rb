class Booking < ActiveRecord::Base

  belongs_to :user

  has_many :seatings, :dependent => :destroy
  has_many :tabels, :through => :seatings

  validates_presence_of :user_id, :arrival, :booking_date  #add time check
  validates_presence_of :contact, :customer_name, :unless => :walk_in?
  validates_numericality_of :pax

  def walk_in?
    walkin
  end

end
