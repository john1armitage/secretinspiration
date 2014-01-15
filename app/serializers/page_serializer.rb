class PageSerializer < ActiveModel::Serializer
  attributes :id, :title, :sub, :body, :user_id, :credit, :publish, :release
  has_one :topic_id
end
