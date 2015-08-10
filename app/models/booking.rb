class Booking < ActiveRecord::Base

  attr_accessor :management

  belongs_to :user

  has_many :seatings, :dependent => :destroy
  has_many :tabels, :through => :seatings

  validates_presence_of :user_id, :arrival, :booking_date  #add time check
  validates_presence_of :contact, :customer_name, :unless => :walk_in?
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, :unless => :management?
  validates_numericality_of :pax

  def walk_in?
    walkin
  end

  def management?
    management == 'true'
  end

end
