class PayRateSerializer < ActiveModel::Serializer
  attributes :id, :effective_date, :rate
  has_one :employee
end
