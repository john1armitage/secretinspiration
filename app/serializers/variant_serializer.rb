class VariantSerializer < ActiveModel::Serializer
  attributes :id, :item_id, :name, :description, :price, :item_default, :stock, :available_on
end
