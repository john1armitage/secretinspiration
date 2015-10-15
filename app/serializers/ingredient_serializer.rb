class IngredientSerializer < ActiveModel::Serializer
  attributes :id, :name, :supplier_id, :reference, :quantity, :unit_id, :live, :notes, :text
end
