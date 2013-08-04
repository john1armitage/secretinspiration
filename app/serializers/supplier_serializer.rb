class SupplierSerializer < ActiveModel::Serializer
  attributes :id, :name, :phone1, :phone2, :email, :notes, :opening_balance
end
