class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :event_date, :reference, :credit_amount, :debit_amount
end
