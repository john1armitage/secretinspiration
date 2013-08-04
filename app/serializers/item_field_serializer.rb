class ItemFieldSerializer < ActiveModel::Serializer
  attributes :id, :name, :field_type, :required, :item_type
end
