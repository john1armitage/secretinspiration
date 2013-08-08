class TransferSerializer < ActiveModel::Serializer
  attributes :id, :transfer_date, :exchange_rate
  has_one :bank
  has_one :recipient
end
