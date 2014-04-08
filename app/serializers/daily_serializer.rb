class DailySerializer < ActiveModel::Serializer
  attributes :id, :account_date, :turnover, :tips, :headcount, :session
end
