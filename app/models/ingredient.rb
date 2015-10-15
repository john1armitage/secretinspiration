class Ingredient < ActiveRecord::Base

  belongs_to :supplier
  belongs_to :unit, class_name: 'Element'
  belongs_to :quantity, class_name: 'Element'
  has_many :recipes, :dependent => :destroy

  validates :name, uniqueness: true, presence: true
  validates :quantity_id, presence: true
  validates :unit_id, presence: true

end
