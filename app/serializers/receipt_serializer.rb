class ReceiptSerializer < ActiveModel::Serializer
  attributes :id, :receipt_date, :amount, :exchange_rate, :home_amount, :state, :receivable_type, :receivable_id
  has_one :bank
end
