class Seating < ActiveRecord::Base
  belongs_to :tabel
  belongs_to :booking

  has_many :meals, :dependent => :destroy

end
