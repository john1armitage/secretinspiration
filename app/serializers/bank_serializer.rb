class BankSerializer < ActiveModel::Serializer
  attributes :id, :name, :sort_code, :account_no, :opening_balance, :notes
end
