class RecipeSerializer < ActiveModel::Serializer
  attributes :id, :item_id, :ingredient_id, :amount_id
end
