class OpeningSerializer < ActiveModel::Serializer
  attributes :id, :start_date, :repeat, :frequency, :string, :status, :message, :string
end
