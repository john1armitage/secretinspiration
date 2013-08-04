class AccountSerializer < ActiveModel::Serializer
  attributes :id, :name, :code, :ancestry, :opening_balance
end
