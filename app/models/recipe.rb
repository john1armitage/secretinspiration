class Recipe < ActiveRecord::Base

  belongs_to :ingredient
  belongs_to :amount, class_name: 'Element'
  belongs_to :item

  validates :item_id, presence: true
  validates :amount_id, presence: true
  validates :ingredient_id, presence: true

end
