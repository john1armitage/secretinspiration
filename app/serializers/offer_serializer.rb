class OfferSerializer < ActiveModel::Serializer
  attributes :id, :days, :offer_type, :amount, :name, :desc, :notes, :live
end
