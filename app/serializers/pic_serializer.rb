class PicSerializer < ActiveModel::Serializer
  attributes :id, :name, :image, :viewable_type, :viewable_id
end
