class TabelSerializer < ActiveModel::Serializer
  attributes :id, :code, :variant, :capacity
end
