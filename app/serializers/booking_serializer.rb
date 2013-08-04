class BookingSerializer < ActiveModel::Serializer
  attributes :id, :arrival, :state, :pax, :notes
  has_one :customer
  has_one :user
end
