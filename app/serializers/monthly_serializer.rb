class MonthlySerializer < ActiveModel::Serializer
  attributes :id, :takings, :credit_card, :cash, :tax, :turnover, :cash_used
end
